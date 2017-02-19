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
|- Services []
  |- item
    |- name (e.g. 500px)
    |- key (e.g. kjdfjhUYERHJ7435438)
  |- item
    |- name (e.g. Instagram)
    |- key (e.g. kjdfjhUYERHJ7435438)
```

## Testing

Run the following command from the project root:

```
$ rake test
```

Or just press `⌘ + U` in Xcode.

## License

MIT, for details check [LICENSE]().
