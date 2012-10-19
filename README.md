AnyJSON
-------

**Encode / Decode JSON By Any Means Possible**

What was once the most egregious part of [AFNetworking](https://github.com/afnetworking/afnetworking) has been spun off into its own library.

This is a library about getting things to work, because there are more important things that you have to do than futz around with an interchange format. 

AnyJSON provides a function to encode and a function to decode JSON, using the first available of the following 3rd-party libraries:

- [JSONKit](https://github.com/johnezang/JSONKit)
- [yajl_json](http://gabriel.github.com/yajl-objc/)
- [SBJSON](http://stig.github.com/json-framework/)
- [NextiveJSON](https://github.com/nextive/NextiveJson)

If none of these libraries are included in the target, AnyJSON falls back on ``NSJSONSerialization`, if available. To prefer `NSJSONSerialization` and fall back on the first available 3rd-party framework, `#define _ANYJSON_PREFER_NSJSONSERIALIZATION_`somewhere in your project.

Why anyone can have such strong opinions about functionality that--in so many cases--accounts for such an insignificant percentage of overall runtime is a mystery. But sometimes it's better not to press the issue, and just be as accommodating as you can. AnyJSON keeps the peace.

## Usage

### Decoding

```objective-c
NSData *data = [@"{\"foo\": 42}" dataUsingEncoding:NSUTF8StringEncoding];
NSError *error = nil;
id JSON = AnyJSONDecode(data, &error);
if (error) {
  NSLog(@"Error: %@", error);
}
```

### Encoding

```objective-c
NSArray *array = [NSArray arrayWithObjects:@"foo", @"bar", @"baz"];
NSError *error = nil;
id JSON = AnyJSONEncode(array, &error);
if (error) {
  NSLog(@"Error: %@", error);
}
```

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

AnyJSON is available under the MIT license. See the LICENSE file for more info.
