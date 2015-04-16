require 'formula'

class MyPhp56 < Formula
  homepage 'https://github.com/n0ts/homebrew-myformula'
  url 'https://github.com/n0ts/homebrew-myformula/blob/master/my-php56.rb'
  version 'latest'

  depends_on 'php56' => ['--without-apache', '--with-fpm', '--with-mysql', '--with-postgresql']
  depends_on 'php56-imagick'
  depends_on 'php56-mcrypt'
  depends_on 'php56-mecab'
  depends_on 'php56-memcached'
  depends_on 'php56-msgpack'
  depends_on 'php56-pdo-pgsql'
  depends_on 'php56-propro'
  depends_on 'php56-qr'
  depends_on 'php56-raphf'
  depends_on 'php56-redis'

  def install
    # nothing to be installed.
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
    5.6
  end
end
