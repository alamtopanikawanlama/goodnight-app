require 'rails_helper'

RSpec.describe BaseService, type: :service do
  let(:test_service_class) do
    Class.new(BaseService) do
      def call
        success('test data', 'test message')
      end
    end
  end

  describe '.call' do
    it 'creates a new instance and calls the call method' do
      service_instance = double
      allow(test_service_class).to receive(:new).and_return(service_instance)
      allow(service_instance).to receive(:call)

      test_service_class.call

      expect(test_service_class).to have_received(:new)
      expect(service_instance).to have_received(:call)
    end
  end

  describe '#call' do
    it 'raises NotImplementedError for base service' do
      service = BaseService.new
      expect { service.call }.to raise_error(NotImplementedError, "BaseService must implement #call")
    end
  end

  describe 'private methods' do
    let(:service) { test_service_class.new }

    describe '#success' do
      it 'returns a successful ServiceResult' do
        result = service.send(:success, 'data', 'message')
        
        expect(result).to be_a(ServiceResult)
        expect(result.success?).to be true
        expect(result.data).to eq('data')
        expect(result.message).to eq('message')
      end
    end

    describe '#failure' do
      it 'returns a failed ServiceResult' do
        result = service.send(:failure, 'error message', ['error1', 'error2'])
        
        expect(result).to be_a(ServiceResult)
        expect(result.failure?).to be true
        expect(result.message).to eq('error message')
        expect(result.errors).to eq(['error1', 'error2'])
      end
    end
  end
end

RSpec.describe ServiceResult do
  describe 'initialization' do
    it 'creates a successful result' do
      result = ServiceResult.new(success: true, data: 'test', message: 'success')
      
      expect(result.success?).to be true
      expect(result.failure?).to be false
      expect(result.data).to eq('test')
      expect(result.message).to eq('success')
      expect(result.errors).to eq([])
    end

    it 'creates a failed result' do
      result = ServiceResult.new(success: false, message: 'error', errors: ['error1'])
      
      expect(result.success?).to be false
      expect(result.failure?).to be true
      expect(result.message).to eq('error')
      expect(result.errors).to eq(['error1'])
    end
  end
end
