#
# We need this extension to help solve the issue with UTF-8 we will keep getting
# #

class String

  #
  # Method from gitlab source code
  # #
  def to_utf8
    detect = CharlockHolmes::EncodingDetector.detect(self)
    if detect
      begin
        CharlockHolmes::Converter.convert(self, detect[:encoding], 'UTF-8')
      rescue ArgumentError => e
        Rails.logger.warn("Ignoring error converting #{detect[:encoding]} into UTF8: #{e.message}")
        ''
      end
    else
      clean(self)
    end
  end
end
