require 'config'

describe 'Configuration' do
  config = Configuration.new
  describe 'Initialize config object with sensible defaults' do
    it 'has instance variable @stage of String type' do
      expect(config.stage.class.to_s).to eq("String")
    end
    it 'has instance variable @prod of String type' do
      expect(config.prod.class.to_s).to eq("String")
    end
    it 'has instance variable @ignored of Array type' do
      expect(config.ignored.class.to_s).to eq("Array")
    end
    it 'has instance variable @SCREEN_RESOLUTION of Hash type' do
      expect(config.SCREEN_RESOLUTION.class.to_s).to eq("Hash")
    end
    it 'has instance variable @IMAGE_THRESHOLD of Fixnum type' do
      expect(config.IMAGE_THRESHOLD.class.to_s).to eq("Fixnum")
    end
    it 'has instance variable @LOGIN of Bool type' do
      expect(config.LOGIN.class.to_s).to eq("TrueClass")
    end
    it 'has instance variable @LOGIN_URI of String type' do
      expect(config.LOGIN_URI.class.to_s).to eq("String")
    end
    it 'has instance variable @USER_DOM_ID of String type' do
      expect(config.USER_DOM_ID.class.to_s).to eq("String")
    end
    it 'has instance variable @USER_VALUE of String type' do
      expect(config.USER_VALUE.class.to_s).to eq("String")
    end
    it 'has instance variable @PASS_DOM_ID of String type' do
      expect(config.PASS_DOM_ID.class.to_s).to eq("String")
    end
    it 'has instance variable @PASS_VALUE of String type' do
      expect(config.PASS_VALUE.class.to_s).to eq("String")
    end
    it 'has instance variable @LOGIN_CONFIRM of Bool type' do
      expect(config.LOGIN_CONFIRM.class.to_s).to eq("TrueClass").or eq("FalseClass")
    end
    it 'has instance variable @LOGIN_CONFIRM_CHECK of Bool type' do
      expect(config.LOGIN_CONFIRM_CHECK.class.to_s).to eq("String")
    end
    it 'has instance variable @WHITELIST of Array type' do
      expect(config.WHITELIST.class.to_s).to eq("Array")
    end
  end
end
