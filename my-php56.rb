require "#{ENV['HOMEBREW_ROOT']}/Library/Taps/homebrew/homebrew-php/Abstract/abstract-php.rb"

class MyPhp56 < AbstractPhp
  init
  include AbstractPhpVersion::Php56Defs

  url     PHP_SRC_TARBALL
  sha256  PHP_CHECKSUM[:sha256]
  version PHP_VERSION

  head    PHP_GITHUB_URL, :branch => PHP_BRANCH

  # Leopard requires Hombrew OpenSSL to build correctly
  depends_on 'openssl' if MacOS.version == :leopard

  ##
  conflicts_with "php56"

  depends_on 'postgresql'

  def install_args
    args = super
    args << "--with-homebrew-openssl" if MacOS.version == :leopard
    args << "--enable-zend-signals"
    args << "--enable-dtrace" if build.without? 'phpdbg'
    # dtrace is not compatible with phpdbg: https://github.com/krakjoe/phpdbg/issues/38
    if build.without? 'phpdbg'
      args << "--disable-phpdbg"
    else
      args << "--enable-phpdbg"
      if build.with? 'debug'
        args << "--enable-phpdbg-debug"
      end
    end
    if build.include? 'disable-opcache'
      args << "--disable-opcache"
    else
      args << "--enable-opcache"
    end

    ##
    args << "--with-pgsql=#{Formula['postgresql'].opt_prefix}"
    args << "--with-pdo-pgsql=#{Formula['postgresql'].opt_prefix}"
    args << "--with-xsl=" + Formula['libxslt'].opt_prefix.to_s
  end

  def php_version
    5.6
  end

  def php_version_path
    56
  end

  ##
  def post_install
    FileUtils.copy(config_path+"php.ini", config_path+"php-default.ini") unless File.exist? config_path+"php-default.ini"

    if File.exist? config_path+"php.ini"
      begin
        inreplace config_path+"php.ini", ";include_path = \".:\/php\/includes\"",
                                         "include_path = \"#{config_path}/conf.d\""
        inreplace config_path+"php.ini", "memory_limit = 128M", "memory_limit = 1024M"
        inreplace config_path+"php.ini", "post_max_size = 8M", "post_max_size = 1024M"
        inreplace config_path+"php.ini", "upload_max_filesize = 2M", "upload_max_filesize = 1024M"

        timezone =
          case Time.now.strftime("%Z")
          when "JST"
            "Asia/Tokyo"
          else
            "UTC"
          end
        inreplace config_path+"php.ini", ";date.timezone =", "date.timezone = #{timezone}"
      rescue
        # ignore
      end
    end

    system "mkdir #{config_path}/conf.d" unless File.exist? "#{config_path}/conf.d"

    unless File.exist? "#{config_path}/conf.d/_local.ini"
      timezone =
        case Time.now.strftime("%Z")
        when "JST"
          "Asia/Tokyo"
        else
          "UTC"
        end
      File.open("#{config_path}/conf.d/_local.ini", "w") do |f|
        f.puts <<-EOS
[PHP]
;; PHP's default character set is set to empty.
;; http://www.php.net/manual/en/ini.core.php#ini.default-charset
default_charset = "UTF-8"
EOS
      end
    end
  end
end
