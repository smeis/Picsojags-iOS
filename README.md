# Picsojags

Your source of daily Jaguar photos. The car, not the cat.

## Setup

To perform the necessary steps to compile this project, run the following command in the project root:

```
$ rake setup
```

Most importantly, it copies the services configration from ```Config/PhotoServices-sample.plist``` to ```Config/PhotoServices.plist```.

### Configuration

Add the API keys required for the services you intend to use to ```Config/PhotoServices-sample.plist```. The plist layout is as follows:

```
- root
|- Services: Dictionary 
  |- 500px: kjdfjhUYERHJ7435438
```

**Note:** I don't recommend storing your API keys in you app this way; they're easily accessed by looking through your app's resources. It's just a convenient way to hide keys from git commits in an open-source project, like this.

## Testing

Run the following command from the project root:

```
$ rake test
```

Or just press `⌘ + U` in Xcode.

## Documentation

Generate the documentation by calling:

```
$ rake docs
```

Access the generated code reference by opening `Docs/index.html`.

## License

MIT, for details check [LICENSE]().
