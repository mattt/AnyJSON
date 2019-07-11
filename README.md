## AnyJSON

**Encode / Decode JSON By Any Means Possible**

AnyJSON implements the `NSJSONSerialization` API
for platforms that don't support it ---
namely iOS < 5 and Mac OS X < 10.7 ---
using the first available of the following 3rd-party libraries:

- [JSONKit](https://github.com/johnezang/JSONKit)
- [yajl_json](https://github.com/gabriel/yajl-objc)
- [SBJSON](https://github.com/stig/json-framework)
- [NextiveJSON](https://github.com/nextive/NextiveJson)

> For anyone who appreciates lower-level Objective-C hacks,
> you won't want to miss
> [how AnyJSON works its magic](https://github.com/mattt/AnyJSON/blob/master/AnyJSON/AnyJSON.m#L247).

## Compatibility

### Supported Methods

The following methods are supported by AnyJSON:

```objective-c
+ (id)JSONObjectWithData:(NSData *)data
                 options:(NSJSONReadingOptions)opt
                   error:(NSError **)error

+ (NSData *)dataWithJSONObject:(id)obj
                       options:(NSJSONWritingOptions)opt
                         error:(NSError **)error
```

### Supported Reading Options

- `NSJSONReadingMutableContainers` is supported only by JSONKit
- `NSJSONReadingMutableLeaves` is not supported
  (it doesn't even work with `NSJSONSerialization` on iOS 5+).
- `NSJSONReadingAllowFragments` is not supported,
  though NextiveJSON always allows fragments

### Supported Writing Options

- `NSJSONWritingPrettyPrinted` is supported by JSONKit, yajl_json, and SBJSON

### Unsupported Methods

The following methods are not currently supported by AnyJSON,
and instead throw an `AnyJSONUnimplementedException` exception when called:

```objective-c
+ (id)JSONObjectWithStream:(NSInputStream *)stream
                   options:(NSJSONReadingOptions)opt
                     error:(NSError **)error

+ (NSInteger)writeJSONObject:(id)obj
                    toStream:(NSOutputStream *)stream
                     options:(NSJSONWritingOptions)opt
                       error:(NSError **)error

+ (BOOL)isValidJSONObject:(id)obj
```

## Contact

- [Cédric Luthi](https://twitter.com/0xced)
- [Mattt](https://twitter.com/mattt)

## License

AnyJSON is available under the MIT license.
See the LICENSE file for more info.
