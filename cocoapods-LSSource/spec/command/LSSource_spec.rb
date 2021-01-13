require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Lssource do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ LSSource }).should.be.instance_of Command::Lssource
      end
    end
  end
end

