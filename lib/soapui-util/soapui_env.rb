module SoapuiUtil
  class SoapuiEnv

    def check_java_home
      if ENV['JAVA_HOME'].nil?
        raise 'JAVA_HOME environment variable must be set to a sun_j2e'
      else
        if ENV['LD_LIBRARY_PATH'].nil?
          ENV['LD_LIBRARY_PATH'] = File.join(ENV['JAVA_HOME'], 'lib')
        end
      end
    end

  end
end