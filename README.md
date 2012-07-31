
### Getting started

* Setup dictybase Oracle instance from binary dump files.
* Checkout this repository from Github, preferably use the master or release branch. 
```
git clone git@github.com:dictyBase/ontopub-multi.git OntoPub-Multi
```
* Make a log folder
```
mkdir log
```
* **Install dependencies**
	* `source` the `deploy/fcgi` script
	* Run `before_install_dependencies`, `carton install` and `after_install_dependencies` in that order. This will take care of all the required dependencies for running the web application.
* The `public` folder contains all the javascripts and css files. It is a `git submodule` and needs to be populated
```
git submodule update --init
```
* **Config for `development` mode**
```
cp conf/sample.yaml conf/development.yaml
```
Change the values as needed to point the the database server.

* Standalone server
You can run the application by starting a standalone server
```
carton exec -- script/ontopub-multi daemon
```

