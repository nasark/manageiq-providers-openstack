module ManageIQ::Providers::Openstack::CloudManager::VmOrTemplateShared::Scanning
  extend ActiveSupport::Concern

  included do
    supports :smartstate_analysis do
      feature_supported, reason = check_feature_support('smartstate_analysis')
      unless feature_supported
        unsupported_reason_add(:smartstate_analysis, reason)
      end
      if storage.nil?
        unsupported_reason_add(:smartstate_analysis, "Vm is not located on a storage")
      end
      unless storage.storage_type_supported_for_ssa?
        unsupported_reason_add(:smartstate_analysis, "Smartstate Analysis unsupported for storage type %{store_type}" % {:store_type => storage.store_type})
      end
    end
  end

  #
  # Adjustment Multiplier is 4 (i.e. 4 times the specified timeout)
  #
  # TODO: until we get location/offset read capability for OpenStack
  #   image data, OpenStack scanning is prone to timeout (based on image size).
  #
  # Maybe this should be calculated based on the size of the image (on the instance method),
  #   but that information isn't directly available.
  #
  module ClassMethods
    def scan_timeout_adjustment_multiplier
      4
    end
  end

  def scan_job_class
    ManageIQ::Providers::Openstack::CloudManager::Scanning::Job
  end

  def require_snapshot_for_scan?
    false
  end
end
