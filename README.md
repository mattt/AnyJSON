AnyJSON
-------

**Encode / Decode JSON By Any Means Possible**

What was once the most egregious part of [AFNetworking](https://github.com/afnetworking/afnetworking) has been spun off into its own library.

This is a library about getting things to work, because there are more important things that you have to do than futz around with an interchange format. 

AnyJSON implements the `NSJSONSerialization` API on platforms that do not support it (i.e. iOS < 5) using the first available of the following 3rd-party libraries:

- [JSONKit](https://github.com/johnezang/JSONKit)
- [yajl_json](http://gabriel.github.com/yajl-objc/)
- [SBJSON](http://stig.github.com/json-framework/)
- [NextiveJSON](https://github.com/nextive/NextiveJson)

Why anyone can have such strong opinions about functionality that--in so many cases--accounts for such an insignificant percentage of overall runtime is a mystery. But sometimes it's better not to press the issue, and just be as accommodating as you can. AnyJSON keeps the peace.

## Compatibility

### Supported methods

The following methods are supported by AnyJSON.

`+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error`
`+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error`

### Supported reading options

* `NSJSONReadingMutableContainers` is supported by JSONKit only.
* `NSJSONReadingMutableLeaves` is not supported. Note that it does not even work with NSJSONSerialization on iOS 5+.
* `NSJSONReadingAllowFragments` is not supported but NextiveJSON always allows fragments.

### Supported writing options

* `NSJSONWritingPrettyPrinted` is supported by JSONKit, yajl_json and SBJSON.

### Unsupported methods

The following methods are currently not supported by AnyJSON. They throw an `AnyJSONUnimplementedException` exception.

`+ (id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error`
`+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error`
`+ (BOOL)isValidJSONObject:(id)obj`

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

AnyJSON is available under the MIT license. See the LICENSE file for more info.
