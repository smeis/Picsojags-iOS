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
  |- Instagram: KJkjhdfsjHewr348z 
```

## Testing

Run the following command from the project root:

```
$ rake test
```

Or just press `⌘ + U` in Xcode.

## License

MIT, for details check [LICENSE]().
