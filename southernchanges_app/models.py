import re
import datetime

from django.utils.safestring import mark_safe
from django.db import models

from eulexistdb.manager import Manager
from eulexistdb.models import XmlModel
from eulxml.xmlmap.core import XmlObject 
#from eulxml.xmlmap.dc import DublinCore
from eulxml.xmlmap.fields import StringField, NodeField, StringListField, NodeListField, IntegerField
from eulxml.xmlmap.teimap import Tei, TeiDiv, _TeiBase, TEI_NAMESPACE, xmlmap, TeiInterpGroup, TeiInterp


class Fields(_TeiBase):
    ROOT_NAMESPACES = {
        'tei' : TEI_NAMESPACE,
        'xml' : 'http://www.w3.org/XML/1998/namespace'}
    id = StringField('@xml:id')
    head = StringField('tei:head')
    author = StringField("tei:byline//tei:sic")
    type = StringField("@type") 
    num = StringField("@n")
    pages = StringField("tei:docDate")
    ana = StringField("@ana")
    
class TeiDoc(Tei):
    divs = xmlmap.NodeListField('//tei:div2', Fields)


class Issue(XmlModel, Tei):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager('/tei:TEI')
    id = StringField('@xml:id')
    divs = NodeListField('//tei:div2', Fields)
    pids = NodeListField('//tei:idno', Fields)
    date = StringField('//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:date/@when')
    head = StringField('//tei:div1/tei:head')
    year = StringField('//tei:div1/tei:p/tei:date')

    site_url = 'http://beck.library.emory.edu/southernchanges'
    source = StringField('tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl')
    issued_date = StringField('tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:date')
    created_date = StringField('tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:date/@when')
    author = StringField('tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl/tei:publisher')
    identifier_ark = StringField('tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type="ark"]')
    title = StringField('tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title')
    publisher = StringField('tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:publisher')
    rights = StringField('tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/tei:p')
    series = StringField('tei:teiHeader/tei:fileDesc/tei:seriesStmt/tei:title')
    project_desc = StringField('tei:teiHeader/tei:encodingDesc/tei:projectDesc')


    @property
    def dc_fields(self):
        dc = DublinCore()
        dc.title = self.title
        dc.creator = self.author
        dc.identifier = self.identifier_ark
        dc.publisher = self.header.publisher
        dcterms.issued = self.issued_date
        dcterms.created = self.created_date
        dc.rights = self.header.rights
        dcterms.isPartOf = self.series
        dc.source = self.source
        dcterms.description = self.divs
        dcterms.hasPart = self.pids

class Article(XmlModel, TeiDiv):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager("//tei:div2")
    article = NodeField("//tei:div2", "self")
    id = NodeField('@xml:id', 'self')
    # pid = NodeField('ancestor::tei:TEI//tei:idno[@n=%s]' % id, Issue)
    date = StringField('tei:docDate/@when')
    head = StringField('tei:head')
    author = StringField("tei:byline//tei:sic")
    type = StringField("@type")
    pages = StringField("tei:docDate")

    issue = NodeField('ancestor::tei:TEI', Issue)
    issue_id = NodeField('ancestor::tei:TEI/@xml:id', Issue)
    issue_title = NodeField('ancestor::tei:TEI//tei:div1/tei:head', Issue)

    nextdiv = NodeField("following::tei:div2[1]", Fields)
    prevdiv = NodeField("preceding::tei:div2[1]", Fields)
     

    
    ana = StringField("@ana", "self") 
   
class Topics(XmlModel):
    objects = Manager("//interp")
    id = StringField('@xml:id')
    name = StringField("//interp", "self")
    
class Topic(XmlModel, Tei):
    ROOT_NAMESPACES = {'tei' : TEI_NAMESPACE}
    objects = Manager('//tei:certainty')
    ana = StringField("@ana")
    degree = StringField("@degree")
    article = NodeField("ancestor::tei:div2", Article)

   
