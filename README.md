AnyJSON
-------

**Encode / Decode JSON By Any Means Possible**

AnyJSON implements the `NSJSONSerialization` API on platforms that do not support it (i.e. iOS < 5 and Mac OS X < 10.7), using the first available of the following 3rd-party libraries:

- [JSONKit](https://github.com/johnezang/JSONKit)
- [yajl_json](http://gabriel.github.com/yajl-objc/)
- [SBJSON](http://stig.github.com/json-framework/)
- [NextiveJSON](https://github.com/nextive/NextiveJson)

> For anyone who appreciates lower-level Objective-C hacks, you won't want to miss [how AnyJSON works its magic](https://github.com/mattt/AnyJSON/blob/master/AnyJSON/AnyJSON.m#L247).

## Compatibility

### Supported Methods

The following methods are supported by AnyJSON.

`+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error`
`+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error`

### Supported Reading Options

- `NSJSONReadingMutableContainers` is supported by JSONKit only.
- `NSJSONReadingMutableLeaves` is not supported (it doesn't even work with `NSJSONSerialization` on iOS 5+).
- `NSJSONReadingAllowFragments` is not supported but NextiveJSON always allows fragments.

### Supported Writing Options

- `NSJSONWritingPrettyPrinted` is supported by JSONKit, yajl_json, and SBJSON.

### Unsupported Methods

The following methods are currently not supported by AnyJSON, and throw an `AnyJSONUnimplementedException` exception.

- `+ (id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error`
- `+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error`
- `+ (BOOL)isValidJSONObject:(id)obj`

## Contact

Cédric Luthi
- http://github.com/0xced
- http://twitter.com/0xced
- cedric.luthi@gmail.com

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- m@mattt.me

## License

AnyJSON is available under the MIT license. See the LICENSE file for more info.
