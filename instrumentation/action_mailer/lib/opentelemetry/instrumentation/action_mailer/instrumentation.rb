# frozen_string_literal: true

# Copyright The OpenTelemetry Authors
#
# SPDX-License-Identifier: Apache-2.0

module OpenTelemetry
  module Instrumentation
    module ActionMailer
      # The Instrumentation class contains logic to detect and install the ActionMailer instrumentation
      class Instrumentation < OpenTelemetry::Instrumentation::Base
        MINIMUM_VERSION = Gem::Version.new('6.1.0')
        install do |_config|
          resolve_email_address
          require_dependencies
        end

        present do
          defined?(::ActionMailer)
        end

        compatible do
          gem_version >= MINIMUM_VERSION
        end

        option :disallowed_notification_payload_keys, default: [:mail], validate: :array
        option :notification_payload_transform,       default: nil, validate: :callable
        option :email_address,                        default: :omit, validate: %I[omit include]

        private

        def gem_version
          ::ActionMailer.version
        end

        def resolve_email_address
          return unless ActionMailer::Instrumentation.instance.config[:email_address] == :omit

          ActionMailer::Instrumentation.instance.config[:disallowed_notification_payload_keys] += %i[to from bcc cc]
        end

        def require_dependencies
          require_relative 'railtie'
        end
      end
    end
  end
end
