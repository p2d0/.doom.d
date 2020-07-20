import unittest

class wattest(unittest.TestCase):

	def setUp(self):
		pass

	def tearDown(self):
		pass

	def test_test(self):
		self.assertEqual('foo'.upper(), 'FOO');

		if __name__ == '__main__':
			unittest.main()
