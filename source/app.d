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
}

void main() {
    test_0();
}