module Calabash
  module IOS
    module Routes

      # !@visibility private
      module PlaybackRouteMixin

        # This is a Legacy API and is only used to support rotations.
        #
        # form_factor is iphone | ipad
        #
        # **NOTE** If we revive this API, move the call to
        # recalibrate_after_rotation closer to the actually implementation of
        # rotate; it is (probably?) not necessary for all recordings.
        def playback_route(recording_name, form_factor)
          request = make_playback_request(recording_name, form_factor)
          response = route_post_request(request)
          result = playback_route_handle_response(response)

          # The first query after a rotation will have incorrect coordinates!
          # We have to make a uia query to force an update.
          recalibrate_after_rotation
          result
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

        def make_playback_parameters(data)
          %Q|{"events":"#{data}"}|
        end

        def make_playback_request(recording_basename, form_factor)
          path = path_to_recording(recording_basename, form_factor)
          data = read_recording(path)
          to_post = make_playback_parameters(data)
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

        def recalibrate_after_rotation
          uia_serialize_and_call(:query, 'window')
        end
      end
    end
  end
end
