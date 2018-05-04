# openshift-php-bare
This is a bare php pod. It does not include Nginx, or Apache. The purpose of this is to use the build in php web server for ease of use. You can put a Nginx or Apache Pod infront of this to take advantage of it. Separating the pods Nginx / Apache / PHP allows for individual scaling on either the LB or PHP Pod as needed.


## Usage
` oc new-build https://github.com/Digi59404/openshift-php-bare`