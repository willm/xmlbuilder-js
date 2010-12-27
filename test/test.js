var xml = '<root>' +
            '<xmlbuilder for="node-js" awesome="CoffeeScript">' +
              '<repo type="git">git://github.com/oozcitak/xmlbuilder-js.git</repo>' +
            '</xmlbuilder>' +
            '<test>complete</test>' +
            '<cdata><![CDATA[<test att="val">this is a test</test>]]></cdata>' +
          '</root>';

var builder = require('../lib/index.js');
builder.begin('root')
  .ele('xmlbuilder')
    .att('for', 'node-js')
    .att('awesome', 'CoffeeScript')
    .ele('repo')
      .att('type', 'git')
      .txt('git://github.com/oozcitak/xmlbuilder-js.git')
      .up()
    .up()
  .up()
  .ele('test')
    .txt('complete')
    .up()
  .up()
  .ele('cdata')
    .txt('<![CDATA[<test att="val">this is a test</test>]]>');

var assert = require('assert');
var test = builder.toString();
assert.strictEqual(xml, test);

