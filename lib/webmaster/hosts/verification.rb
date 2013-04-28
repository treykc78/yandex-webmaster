# encoding: utf-8

require 'xml/libxml'

module Webmaster
  module Hosts
    class Verification < Base
      include Virtus

      STATES = [
        'in_progress',
        'never_verified',
        'verification_failed',
        'verified',
        'waiting'
      ].freeze

      CHECKABLE_TYPES = [        
        'dns_record',
        'html_file',        
        'meta_tag',        
        'txt_file',
        'whois'
      ].freeze

      NON_CHECKABLE_TYPES = [
        'auto',
        'manual',        
        'pdd',        
        'pdd_external',
        'delegation'        
      ].freeze

      TYPES = (CHECKABLE_TYPES + NON_CHECKABLE_TYPES).flatten.freeze

      attribute :state, String
      attribute :type, String
      
      attribute :possible_to_cancel, Boolean
      attribute :date, Date
      attribute :uin, String

      attr_accessor :host

      def initialize(attributes = {})
        super(attributes)

        self.state ||= 'never_verified'
      end

      # @return [Boolean]
      # 
      def verified?
        self.state == 'verified'
      end

      def run(type)
        raise ArgumentError if !CHECKABLE_TYPES.include?(type.underscore.downcase)

        # data = XML::Document.string("<host><type>#{type.underscore.upcase}</type></host>").to_s
        data = "<host><type>#{type.underscore.upcase}</type></host>"
        response = self.request(:put, self.host.resources[:verify_host], :data => data)
        # return true if response.status.to_i == 204
      end

      def state=(value)
        value = value.downcase.underscore
        @state = value if STATES.include?(value)
      end

      def type=(value)
        value = value.downcase.underscore
        @type = value if TYPES.include?(value)
      end
    end
  end
end