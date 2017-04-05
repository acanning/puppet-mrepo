# Fact to determine RHN key after subscription

require 'facter'

Facter.add (:rhnkey) do
  # used to use 'puppet resource user | findstr /i admin21ms'
  confine :kernel => :linux
  setcode do
    if File.file?('/sbin/subscription-manager')
      key = Facter::Core::Execution.execute('/sbin/subscription-manager list --consumed --matches="Red Hat Enterprise Linux Server" | grep  "^Serial:" | awk \'{ print $2 }\'')
      if key.nil? || key.empty?
        key=false 
      end
    else
      key=false
    end
    key
  end
end
