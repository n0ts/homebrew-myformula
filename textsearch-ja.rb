class TextsearchJa < Formula
  homepage 'http://textsearch-ja.projects.pgfoundry.org/textsearch_ja.html'
  head 'https://github.com/oknj/textsearch_ja.git'
  url 'https://github.com/oknj/textsearch_ja/archive/textsearch_ja-9.6.0.zip'
  sha256 'bfa537cf193cc43c4bcdcd4314d80a2d5838e99a88ee145e87f371a0c8664f08'

  depends_on 'postgresql'
  depends_on 'mecab'
  depends_on 'mecab-ipadic'

  patch :DATA

  def install
    system 'make', 'USE_PGXS=1'
    system 'make', 'USE_PGXS=1', 'install'
  end

  def caveats; <<-EOS.undent
    Register textsearch_ja your database, and start PostgreSQL
      psql -f #{HOMEBREW_PREFIX}/opt/postgresql/share/postgresql/contrib/textsearch_ja.sql <db name>
EOS
  end

  test do
    system 'make', 'test'
  end
end

__END__
--- tesxsearch_ja/Makefile-org	2014-11-16 09:00:25.000000000 +0900
+++ textsearch_ja/Makefile	2014-11-16 09:44:13.000000000 +0900
@@ -3,7 +3,7 @@
 DATA = uninstall_textsearch_ja.sql
 OBJS = textsearch_ja.o encoding_eucjp.o encoding_utf8.o pgut/pgut-be.o
 REGRESS = init convert textsearch_ja
-SHLIB_LINK = -lmecab
+SHLIB_LINK = -lmecab -L${HOMEBREW_ROOT}/opt/mecab/lib

 ifndef USE_PGXS
 top_builddir = ../..
@@ -14,6 +14,8 @@
 endif

 ifdef USE_PGXS
+PG_CPPFLAGS = -I${HOMEBREW_ROOT}/opt/mecab/include
+
 PG_CONFIG = pg_config
 PGXS := $(shell $(PG_CONFIG) --pgxs)
 include $(PGXS)
