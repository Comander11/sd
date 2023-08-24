// Copyright (c) 2023 CVS
// Distributed under the MIT/X11 software license, see the accompanying
// file license http://www.opensource.org/licenses/mit-license.php.

import std.stdio;
import std.stdio;
import std.conv;
import std.bitmanip;
import core.stdc.stdint;
import std.array;
import std.algorithm;
import std.uni : toLower;
import std.format; 
import std.traits;
import std.range;



/**
* Template for checking if a type is a pointer type.
*
* This template provides a way to determine whether a given type is a pointer type.
*
* Template Parameter:
*     T - The type to be checked.
*/
template IsPointerType(T) {
    /**
    * A compile-time constant that indicates whether the provided type is a pointer type.
    *
    * This enum is set to `true` if the provided type is a pointer type, otherwise `false`.
    */
    enum bool IsPointerType = is(typeof(*T.init));
}


/**
* Template for converting values to hexadecimal strings.
* 
* This template provides a way to convert values of different types
* (such as ubyte arrays or strings) to their corresponding hexadecimal
* representation as strings.
*/
template _toHexString(T) {

    string hexString;

    /**
    * Convert a value to its hexadecimal representation as a string.
    *
    * This function handles different types and converts them to a lowercase
    * hexadecimal string.
    *
    * Parameters:
    *     input - The value to be converted to a hexadecimal string.
    * Returns:
    *     The hexadecimal representation of the input value as a lowercase string.
    */
    string toHexString(T input) {
        static if (is(T : ubyte[])) {
            foreach (ret; input) {
                hexString ~= format("%02X", ret);
            }
            return hexString.toLower();
        } else static if (is(T : string)) {
            ubyte[] byteArray = cast(ubyte[])input;
            foreach (ret; byteArray) {
                hexString ~= format("%02X", ret);
            }
            return hexString.toLower();
        } else {
            static assert(0, "Unsupported type in toHexString");
        }
    }
}


/**
* Template for printing hexadecimal representation of byte data.
*
* This template provides a way to print the hexadecimal representation of an array of bytes.
*
* Template Parameter:
*     T - The type of the elements in the data array (usually ubyte or byte).
*
* Parameter:
*     data - The array of data to be printed as hexadecimal bytes.
*/
template PrintBytes(T) {
    /**
    * Print the hexadecimal representation of the given data.
    *
    * This function iterates through the data array and prints each byte in hexadecimal format.
    *
    * Parameter:
    *     data - The array of data to be printed as hexadecimal bytes.
    */
    void PrintBytes(const(T)[] data) {
        foreach (f; data) {
            writef("%02X ", f);
        }
        writeln('\n');
    }
}


/**
* Check if a value is nullable (null).
* 
* This template function uses compile-time introspection to determine
* if the input value can be checked for nullability. If the value is nullable,
* it returns true; otherwise, it returns false.
*
* Template Parameter:
*     T - The type of the value to be checked for nullability.
* Parameter:
*     value - The value to be checked for nullability.
* Returns:
*     true if the value is null, otherwise false.
*/
bool isNullable(T)(T value) {
    static if (__traits(compiles, value is null)) {
        return value is null;
    } else {
        return false;
    }
}


template IsIntegralArrayOfObjects(T) {
    static if (is(T : typeof([]))) { 
        static if (isIntegral!(typeof(T.init[0]))) { 
            enum bool IsIntegralArrayOfObjects = true;
        } else {
            enum bool IsIntegralArrayOfObjects = false;
        }
    } else {
        enum bool IsIntegralArrayOfObjects = false;
    }
}





/**
* Write a compact size value into a byte buffer.
* 
* Compact size encoding is used to efficiently store integers with a
* variable number of bytes. This function repeatedly appends bytes to the buffer,
* each carrying 7 bits of the size value. The most significant bit of each byte
* is used as a continuation flag, indicating whether more bytes follow.
*
* Parameters:
*     size - The size value to be encoded and written.
*     buffer - The byte buffer where the compact size bytes will be written.
*/
void WriteCompactSize(size_t size, ref ubyte[] buffer) {
    while (size >= 0x80) {
        buffer ~= cast(ubyte)(size | 0x80);
        size >>= 7; 
    }
    buffer ~= cast(ubyte)size;
}

/**
* Read a compact size value from a byte buffer.
* 
* This function interprets the bytes from the buffer according to the compact size
* encoding scheme and reconstructs the original size value.
*
* Parameters:
*     size - A reference to the variable where the decoded size value will be stored.
*     buffer - The byte buffer from which the compact size bytes will be read.
*     index - A reference to the index in the buffer, indicating the current position
*             from which bytes will be read and processed.
*/
void ReadCompactSize(ref size_t size, const(ubyte)[] buffer, ref size_t index) {
    size = 0;
    size_t shift = 0;
    ubyte _byte;
    do {
        _byte = buffer[index++]; 
        size |= (cast(size_t)_byte & 0x7F) << shift; 
        shift += 7; 
    } while (_byte & 0x80); 
}




/**
* Template for serializing integral types into a byte buffer.
*/
template IntegralSerialize(T)
{
    /**
    * Serialize an integral member into the buffer.
    *
    * Params:
    *   - member: The integral value to be serialized.
    *   - buffer: The byte buffer to which the serialized data will be added.
    */
    void IntegralSerialize(T)(T member, ref ubyte[] buffer) {
        buffer ~= nativeToLittleEndian!T(member);
    }
}

/**
* Template for serializing arrays of integral types into a byte buffer.
*/
template ArraySerialize(T)
{
    /**
    * Serialize an array of integral values into the buffer.
    *
    * Params:
    *   - member: The array to be serialized.
    *   - buffer: The byte buffer to which the serialized data will be added.
    */
    void ArraySerialize(T)(T member, ref ubyte[] buffer) {
        auto ret = cast(ubyte[])member;
        WriteCompactSize(ret.length, buffer);
        buffer ~= ret;
    }
}

/**
* Template for serializing strings into a byte buffer.
*/
template StringSerialize(T)
{
    /**
    * Serialize a string into the buffer.
    *
    * Params:
    *   - member: The string to be serialized.
    *   - buffer: The byte buffer to which the serialized data will be added.
    */
    void StringSerialize(T)(T member, ref ubyte[] buffer) {
        auto ret = cast(ubyte[])member;
        WriteCompactSize(ret.length, buffer);
        buffer ~= ret;
    }
}

/**
* Template for serializing arrays of objects into a byte buffer.
*/
template ArrayObjectSerialize(T)
{
    /**
    * Serialize an array of objects into the buffer.
    *
    * Params:
    *   - member: The array of objects to be serialized.
    *   - buffer: The byte buffer to which the serialized data will be added.
    */
    void ArrayObjectSerialize(T)(T member, ref ubyte[] buffer) {
        WriteCompactSize(member.length, buffer);

        static if (IsIntegralArrayOfObjects!T) {
            foreach (subMember; member) {
                IntegralSerialize!T(subMember, buffer);
            }
        } else {
            foreach (subMember; member) {
                SERIALIZE(subMember, buffer, buffer);
            }
        }
    }
}





/**
* Template for serializing an object of an unknown type into a byte buffer.
*
* This template handles the case where the data type is not recognized as any of the predefined cases.
* It uses the SERIALIZE template recursively to serialize the unknown type.
*
* Template Parameters:
*   T - The type of the object to be serialized.
*/
template ObjectSerialize(T) {
    /**
    * Serialize an object of unknown type into a byte buffer.
    *
    * @param member The object to be serialized.
    * @param buffer The byte buffer where the serialized data will be written.
    */
    void ObjectSerialize(T member, ref ubyte[] buffer) {
        // Recursively call SERIALIZE to serialize the unknown type
        SERIALIZE(member, buffer, buffer);
    }
}




/**
* Template for deserializing an integral member from a byte array.
*/
template deserializeIntegralMember(MemberType) {
    /**
    * Deserialize an integral member from a byte array.
    *
    * @param member Reference to the member variable to store the deserialized value.
    * @param from The source byte array from which data will be deserialized.
    * @param index Reference to the current index in the byte array. Updated after deserialization.
    */
    void deserializeIntegralMember(ref MemberType member, const(ubyte)[] from, ref size_t index) {
        member = littleEndianToNative!MemberType(to!(ubyte[MemberType.sizeof])(from[index .. index + MemberType.sizeof]));
        index += MemberType.sizeof;
    }
}

/**
* Template for deserializing an unsigned byte array from a byte array.
*/
template deserializeUByteArray(MemberType) {
    /**
    * Deserialize an unsigned byte array from a byte array.
    *
    * @param member Reference to the member variable to store the deserialized byte array.
    * @param from The source byte array from which data will be deserialized.
    * @param index Reference to the current index in the byte array. Updated after deserialization.
    */
    void deserializeUByteArray(ref MemberType member, const(ubyte)[] from, ref size_t index) {
        size_t arraySize;
        ReadCompactSize(arraySize, from, index);
        member = from[index .. index + arraySize].dup;
        index += arraySize;
    }
}

/**
 * Template for deserializing a string from a byte array.
 */
template deserializeString(MemberType) {
    /**
    * Deserialize a string from a byte array.
    *
    * @param member Reference to the member variable to store the deserialized string.
    * @param from The source byte array from which data will be deserialized.
    * @param index Reference to the current index in the byte array. Updated after deserialization.
    */
    void deserializeString(ref MemberType member, const(ubyte)[] from, ref size_t index) {
        size_t stringSize;
        ReadCompactSize(stringSize, from, index);
        member = cast(string) from[index .. index + stringSize];
        index += stringSize;
    }
}



/**
* Template for deserializing an array of objects from a byte array.
*/
template deserializeArrayOfObjects(MemberType) {
    /**
    * Deserialize an array of objects from a byte array.
    *
    * @param member Reference to the member variable to store the deserialized array.
    * @param from The source byte array from which data will be deserialized.
    * @param index Reference to the current index in the byte array. Updated after deserialization.
    */
    void deserializeArrayOfObjects(ref MemberType member, const(ubyte)[] from, ref size_t index) {
        size_t arraySize;
        ReadCompactSize(arraySize, from, index);

        static if (IsIntegralArrayOfObjects!MemberType) {
            MemberType newArray;
            newArray.length = arraySize;

            foreach (j; 0 .. arraySize) {
                deserializeIntegralMember(newArray[j], from, index);
            }

            member = newArray;
        } else {
            static if (is(MemberType == typeof([]))) {
                MemberType newArray;

                foreach (j; 0 .. arraySize) {
                    mixin("typeof(member[0]) element;");
                    DESERIALIZE(element, from, index);
                    newArray ~= element;
                }

                member = newArray;
            } else {
                static assert(0, "Unsupported type in deserializeArrayOfObjects");
            }
        }
    }
}

/*

/**
* Template for deserializing an object of an unknown type from a byte array.
*
* This template handles the case where the data type is not recognized as any of the predefined cases.
* It uses the DESERIALIZE template recursively to deserialize the unknown type.
*
* Template Parameters:
*   T - The type of the object to be deserialized.
*/
template deserializeObject(T) {
    /**
    * Deserialize an object of unknown type from a byte array.
    *
    * @param member Reference to the member variable to store the deserialized object.
    * @param from The source byte array from which data will be deserialized.
    * @param index Reference to the current index in the byte array. Updated after deserialization.
    */
    void deserializeObject(ref T member, const(ubyte)[] from, ref size_t index) {

        T ret;
        DESERIALIZE(ret, from, index);
        member = ret;
    }
}





/**
* Serialize an object into a byte buffer.
* 
* This function serializes an object and its members into a byte buffer.
* It handles various data types, including integral types, byte arrays,
* strings, and arrays of objects. The serialized data is written into the
* 'to' buffer. If a 'prev' buffer is provided, its contents are included
* before the serialized data.
*
* Parameters:
*     obj - The object to be serialized.
*     to - The byte buffer where the serialized data will be written.
*     prev - A byte buffer to be included before the serialized data.
*/
void SERIALIZE(T)(T obj, out ubyte[] to, ubyte[] prev) {
    ubyte[] buffer;

    if (prev !is null)
        buffer ~= prev;

    auto members = obj.tupleof;
    foreach (i, member; members) {

        if (isNullable(member)) {
            WriteCompactSize(0, buffer);
            continue;
        }

        static if (isIntegral!(typeof(member))) { 
            IntegralSerialize!T(member, buffer); 
        } else static if (is(typeof(member) == ubyte[])) {
            ArraySerialize!T(member, buffer); 
        } else static if (is(typeof(member) == string)) { 
            StringSerialize!T(member, buffer); 
        } else static if (is(typeof(member) : typeof([]))) { 
            ArrayObjectSerialize!T(member, buffer); 
        } else { ObjectSerialize(member, buffer);
        }
    }

    to = buffer;
}

/**
* Template for deserializing an object from a byte buffer.
* 
* This template provides a way to deserialize an object from a byte buffer.
* It handles various data types, including integral types, byte arrays,
* strings, and arrays of objects. The deserialized data is assigned to the
* provided 'obj'. The deserialization process starts from the 'index' in the
* 'from' buffer and updates the 'index' accordingly.
*/
template DESERIALIZE(T) {
    void DESERIALIZE(ref T obj, const(ubyte)[] from, ref size_t index) {

        auto members = obj.tupleof;

        foreach (i, member; members) {
            alias MemberType = typeof(member);

            static if (isIntegral!MemberType) {
                deserializeIntegralMember(obj.tupleof[i], from, index);
            } else static if (is(MemberType : ubyte[])) {
                deserializeUByteArray(obj.tupleof[i], from, index);
            } else static if (is(MemberType : string)) {
                deserializeString(obj.tupleof[i], from, index);
            } else static if (is(MemberType : typeof([]))) {
                deserializeArrayOfObjects(obj.tupleof[i], from, index);
            } else { deserializeObject(obj.tupleof[i], from, index);
            }
        }
    }
}