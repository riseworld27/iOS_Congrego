# Congrego #

Congrego is an iPad application interfacing with the Congrego backend, allowing the user to
view documentation made available to them
 
## Requirements ##

Cocoapods - Cocoopods is used as dependency management for this project. 

## Build schemes ##

Build schemes in the application allow builds to be produced for multiple whitelabel clients. 
At present there exists only a default `Congrego` branding, used for demonstration builds,
and `JAZZ Pharma` branding. 

### Adding new branding ###

Add a new target for the application, usually by duplicating an existing target. Configure the
correct Bundle ID for the new brand. 

The Supporting Files/Branding group contains the minimal set of files required for a new brand.
Copy and customise an existing brand - but set the target membership of your new set of resources
to that of your new target.


## Components ##

### IGViewController ##

This is a god objects that is responsible for the entire lifecycle of the app. Initially it will 
present `IGLoginView` to allow a new or returning user to present their credentials. Having done so
the view controller will present a Carousel (`iCarousel`) of different product types, each of 
which will have numerous categories of content.

If the user selects an element of content, they will be given the option to download it (if they
have not done so previously), and then view it.

### Networking ###

This is done using `AFNetworking`. See `UpdateHandler` and related.

## Future development ##

* Refactor user interface to use multiple view controllers and auto-layout
* TouchID login
* Adopt Fastlane to improve build process
* Unit and UI testing
