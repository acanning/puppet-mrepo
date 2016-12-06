# Fact to determine RHN key after subscription

require 'facter'

Facter.add (:rhnkey) do
  # used to use 'puppet resource user | findstr /i admin21ms'
  confine :kernel => :linux
  setcode do
    key = Facter::Core::Execution.execute('ls /etc/pki/entitlement/ | grep  "key.pem" | cut -f1 -d"-"')
    if key.nil? || key.empty?
      key=false 
    end
    key
  end
end
