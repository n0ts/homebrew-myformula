class MyPhp70 < Formula
  homepage 'https://github.com/n0ts/homebrew-myformula'
  url 'https://raw.githubusercontent.com/n0ts/homebrew-myformula/master/README.md'
  version '1.0'
  sha256 'c8ede39a6eb0f919c65ff0a653d84e051a6be5abb4048d1f35628da2191d31e5'

  depends_on 'php70' => ['--without-apache', '--with-fpm', '--with-postgresql']
  depends_on 'php70-imagick'
  depends_on 'php70-mcrypt'
  depends_on 'php70-mecab'
  depends_on 'php70-memcached'
  depends_on 'php70-msgpack'
  depends_on 'php70-pdo-pgsql'
  ## TODO FIX support php 7.0
##  depends_on 'php70-qr'
  depends_on 'php70-redis'
  depends_on 'php70-tidy'

  def install
    # nothing to be installed. (dummy)
    system "touch #{prefix}/dummy"
  end

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

  def config_path
    etc+"php/"+php_version.to_s
  end

  def php_version
    7.0
  end
end
