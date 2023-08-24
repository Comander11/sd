# sd
[![Build Status](https://travis-ci.org/Comander11/sd.svg?branch=master)](https://travis-ci.org/Comander11/sd)

D library for versatile object serialization/deserialization, supporting integral types, arrays, and strings
## Usage





# sd

```D
import std.stdio;
import std.conv;

import serialize;


struct InnerNestedObject {
    int value;
    short short_value;
    string innerNestedName;
}

struct NestedObject {
    int value;
    string nestedName;
    InnerNestedObject innerNested;
}

struct MyObject {
    int value;
    string name;
    ubyte[] data;
    int[] values;
    NestedObject nested;
}


void test_0() {
    // Create a sample MyObject instance
    MyObject myObj;
    myObj.value = 42;
    myObj.name = "Test Object";
    myObj.data = [1, 2, 3];
    myObj.values = [5, 6, 7];
    myObj.nested.value = 100;
    myObj.nested.nestedName = "Nested";
    myObj.nested.innerNested.value = 50;
    myObj.nested.innerNested.short_value = 10;
    myObj.nested.innerNested.innerNestedName = "Inner Nested";

    // Serialize the MyObject instance
    ubyte[] serializedData;
    SERIALIZE(myObj, serializedData, null);

    writeln("Serialized Data:");

    PrintBytes!ubyte(serializedData);

    writeln("Serialized Data:");


    // Deserialize the serialized data back into a MyObject instance
    MyObject deserializedObj;
    size_t index = 0;
    DESERIALIZE(deserializedObj, serializedData, index);

    // Display the deserialized data
    writeln("\nDeserialized Object:");
    writeln("Value: ", deserializedObj.value);
    writeln("Name: ", deserializedObj.name);
    writeln("Data: ", deserializedObj.data);
    writeln("Values: ", deserializedObj.values);
    writeln("Nested Value: ", deserializedObj.nested.value);
    writeln("Nested Name: ", deserializedObj.nested.nestedName);
    writeln("Inner Nested Value: ", deserializedObj.nested.innerNested.value);
    writeln("Inner Nested Short Value: ", deserializedObj.nested.innerNested.short_value);
    writeln("Inner Nested Name: ", deserializedObj.nested.innerNested.innerNestedName);

    assert(myObj == deserializedObj);


    // Serialized Data:
    // 2A 00 00 00 0B 54 65 73 74 20 4F 62 6A 65 63 74 03 01 02 03 03 05 00 00 00 06 00 00 00 07 00 00 00 64 00 00 00 06 4E 65 73 74 65 64 32 00 00 00 0A 00 0C 49 6E 6E 65 72 20 4E 65 73 74 65 64 
        
    //Deserialized Object:
    //Value: 42
    //Name: Test Object
    //Data: [1, 2, 3]
    //Values: [5, 6, 7]
    //Nested Value: 100
    //Nested Name: Nested
    //Inner Nested Value: 50
    //Inner Nested Short Value: 10
    //Inner Nested Name: Inner Nested
}

void main() {
    test_0();
}



```

