expect = require('chai').expect
html2enml = require '../lib/html2enml'
path = require 'path'
fs = require 'fs'

describe 'html2enml', ->
  describe '.fromString()', ->
    options =
      baseUrl: 'http://www.google.com/'

    it 'converts basic HTML to ENML', (done) ->
      plainHTML = '<!DOCTYPE html>
                   <html>
                   <body>
                   <h1>A Heading</h1>
                   <p>Some text. <a href="http://www.google.com">And a link.</a></p>
                   </body>
                   </html>'
      html2enml.fromString plainHTML, options, (err, enml) ->
        enmlExpected = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note> <h1>A Heading</h1> <p>Some text. <a href="http://www.google.com">And a link.</a></p> </en-note>'
        expect(err).to.be.null
        expect(enml).to.equal(enmlExpected)
        done()

    it 'converts relative links to absolute links', (done) ->
      relativeHTML = '<!DOCTYPE html>
                      <html>
                      <body>
                      <h1>A Heading</h1>
                      <p>Some text. <a href="resource">And a link.</a></p>
                      </body>
                      </html>'
      html2enml.fromString relativeHTML, options, (err, enml) ->
        enmlExpected = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note> <h1>A Heading</h1> <p>Some text. <a href="http://www.google.com/resource">And a link.</a></p> </en-note>'
        expect(err).to.be.null
        expect(enml).to.equal(enmlExpected)
        done()

    it 'converts internal Evernote URLs', (done) ->
      # Pseudo Evernote notebook url
      relativeHTML = '<!DOCTYPE html>
                      <html>
                      <body>
                      <h1>A Heading</h1>
                      <p>Some text. <a href="evernote:///view/2127483637/s161/01344ac2-be5a-454b-8e01-a0b487cda7e4/01344ac2-be5a-454b-8e01-a0c987cda7e4/">And a link.</a></p>
                      </body>
                      </html>'
      html2enml.fromString relativeHTML, options, (err, enml) ->
        enmlExpected = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note> <h1>A Heading</h1> <p>Some text. <a href="evernote:///view/2127483637/s161/01344ac2-be5a-454b-8e01-a0b487cda7e4/01344ac2-be5a-454b-8e01-a0c987cda7e4/">And a link.</a></p> </en-note>'
        expect(err).to.be.null
        expect(enml).to.equal(enmlExpected)
        done()

    it 'converts local files to ENML resouces', (done) ->
      fileHtml = "<!DOCTYPE html>
                      <html>
                      <body>
                      <h1>A Heading</h1>
                      <p>Some text. <img src=\"file:#{path.join __dirname, 'assets', 'testImg.png'}\"></p>
                      </body>
                      </html>"
      resource =
        data:
          bodyHash: 'd0ad09ba8fe3801ac437d06ba62740d2'
          _body: '�PNG\r\n\u001a\n\u0000\u0000\u0000\rIHDR\u0000\u0000\u0000 \u0000\u0000\u0000 \u0002\u0003\u0000\u0000\u0000\u000e\u0014�g\u0000\u0000\u0000\u0004gAMA\u0000\u0001��1��_\u0000\u0000\u0000\u0003sBIT\u0001\u0001\u0001|.w�\u0000\u0000\u0000\fPLTE\u0000�\u0000�\u0000\u0000��\u0000\u0000\u0000�e?+�\u0000\u0000\u0000"IDATx�c�\u001f��\u0001�\u0019�0���\u0018��,|\f����\u0018��=\u0000�I�ꉎ\u001b\u0000\u0000\u0000\u0000IEND�B`�'
        mime: 'image/png'
      html2enml.fromString fileHtml, options, (err, enml, resources) ->
        enmlExpected = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note> <h1>A Heading</h1> <p>Some text. <en-media hash="d0ad09ba8fe3801ac437d06ba62740d2" type="image/png"></en-media></p> </en-note>'
        expect(err).to.be.null
        expect(enml).to.equal(enmlExpected)
        expect(resources.length).to.equal(1)
        expect(resources[0].data.bodyHash).to.equal(resource.data.bodyHash)
        expect(resources[0].data._body).to.equal(resource.data._body)
        expect(resources[0].mime).to.equal(resource.mime)
        done()

    # TODO: use supertest
    # it 'converts remote files to ENML resouces', (done) ->
    #   remoteHTML = "<!DOCTYPE html>
    #                   <html>
    #                   <body>
    #                   <h1>A Heading</h1>
    #                   <p>Some text. <img src=\"http://www.schaik.com/pngsuite/basn3p02.png\"></p>
    #                   </body>
    #                   </html>"
    #   html2enml.fromString remoteHTML, options, (err, enml, resources) ->
    #     enmlExpected = '<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd"><en-note> <h1>A Heading</h1> <p>Some text. <en-media hash="d0ad09ba8fe3801ac437d06ba62740d2" type="image/png"></en-media></p> </en-note>'
    #     expect(err).to.be.null
    #     expect(enml).to.equal(enmlExpected)
    #     done()
    #
    #     # webHTML = "<!DOCTYPE html>
    #     #                 <html>
    #     #                 <body>
    #     #                 <h1>A Heading</h1>
    #     #                 <p>Some text. <img src=\"http://www.schaik.com/pngsuite/basn3p02.png\"></p>
    #     #                 </body>
    #     #                 </html>"

    # it 'converts HTML entities', (done) ->
    # it 'returns error in strict mode when encountering invalid HTML tags', (done) ->
    # it 'ignores invalid HTML tags when not in strict mode', (done) ->
    # it 'returns error when encountering invalid resources', (done) ->
    # it 'discards invalied resources when not in strict mode', (done) ->

#
#   describe '.fromFile()', () ->
#     it 'should convert file at given path', () ->
