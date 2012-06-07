# Counter

## Summary

An example of a realtime chart with node.js, socket.io and highchart and mysql

## Example

![](http://img708.imageshack.us/img708/7541/realchart.png)

## Installation

Assuming you have [node.js][6], [npm][7], [coffeescript][8] and [mysql][9] installed you can install it with

    git clone https://github.com/bonomat/realchart.git
    cd realchart    
    npm install

Then you can start the server with

    coffee server.coffee

      or

    node server.js

Don't forget to setup a database and change the username and password

Then open `http://localhost:10927` in your favorite browser.

## Credits

There are quite a few tecnologies and libraries used in the demo. Thank you!

* [socket.io][1]
* [stylus][2]
* [jade][3]
* [express][4]
* [highchart][5]
* [node.js][6]
* [npm][7]
* [coffeescript][8]
* [mysql][9]

[1]: https://github.com/LearnBoost/Socket.IO
[2]: https://github.com/LearnBoost/stylus
[3]: https://github.com/visionmedia/jade/
[4]: https://github.com/visionmedia/express
[5]: http://www.highcharts.com/
[6]: https://github.com/joyent/node
[7]: https://github.com/isaacs/npm
[8]: http://coffeescript.org/
[9]: http://www.mysql.com/
