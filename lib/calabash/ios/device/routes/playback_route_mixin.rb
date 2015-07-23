module Calabash
  module IOS
    module Routes

      # !@visibility private
      module PlaybackRouteMixin

        # This is a Legacy API and is only used to support rotations.
        #
        # form_factor is iphone | ipad
        def playback_route(recording_name, form_factor)
          request = make_playback_request(recording_name, form_factor)
          response = route_post_request(request)
          playback_route_handle_response(response)
        end

        private

        PLAYBACK_DIR = File.expand_path(File.join(File.dirname(__FILE__),
                                                  '..', '..', 'lib', 'recordings'))

        def path_to_recording(basename, form_factor)
          name = "#{basename}_#{form_factor}.base64"
          File.join(PLAYBACK_DIR, name)
        end

        def read_recording(path)
          unless File.exist?(path)
            raise "Expected file '#{path}' to exist. Can't load recording."
          end

          File.read(path)
        end

        def make_playback_post_data(data)
          "{\"events\":\"#{data}\"}"
        end

        def make_playback_request(recording_basename, form_factor)
          path = path_to_recording(recording_basename, form_factor)
          data = read_recording(path)
          to_post = make_playback_post_data(data)
          Calabash::HTTP::Request.new('play', to_post)
        end

        def playback_route_handle_response(response)
          hash = parse_response_body(response)
          if hash['outcome'] == 'SUCCESS'
            hash['results']
          else
            raise "Playback failed because:\n#{hash['reason']}\n#{hash['details']}"
          end
        end
      end
    end
  end
end
