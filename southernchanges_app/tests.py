"""
Southern Changes Test Cases
"""
from os import path

from django.conf import settings
from django.core.urlresolvers import reverse
from django.test import TestCase as DjangoTestCase

from eulxml import xmlmap
from eulexistdb.testutil import TestCase

from southernchanges_app.models import Fields, TeiDoc, Issue, Article, Topics, Topic

exist_fixture_path = path.join(path.dirname(path.abspath(__file__)), 'fixtures')
exist_index_path = path.join(path.dirname(path.abspath(__file__)), '..', 'exist_index.xconf')

# extend Issue Model
class TestIssue(Issue):
    articles = xmlmap.NodeListField('//tei:div2', Article)

    
class IssueTestCase(DjangoTestCase):
    # tests for issue model objects

    FIXTURES = ['sc04-3.xml', 'sc17-1.xml', 'sc18-2.xml']

    def setUp(self):

        # load the three xml issue objects
        self.issue = dict()
        for file in self.FIXTURES:
            filebase = file.split('.')[0]
            self.issue[filebase] = xmlmap.load_xmlobject_from_file(path.join(exist_fixture_path, file), TestIssue)

    def test_init(self):
        for file, i in self.issue.iteritems():
            self.assert_(isinstance(i, Issue))

    def test_xml_fixture_load(self):
        self.assertEqual(3, len(self.issue))

    def test_article_model(self):
        self.assertEqual('Allen Tullos', self.issue['sc04-3'].articles[0].author)
        self.assertEqual('sc04-3_1204', self.issue['sc04-3'].articles[0].issue.id)
