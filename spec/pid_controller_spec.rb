require 'spec_helper'
RSpec.describe PidController do
  subject { PidController.new(setpoint: 100.0, kp: kp, ki: ki, kd: kd) }
  let(:kp) { 0.0 }
  let(:ki) { 0.0 }
  let(:kd) { 0.0 }

  # Simulate 1 second ticks between measurements
  before { allow(subject).to receive(:clock_time).and_return(*20.times.to_a) }

  it 'has a version number' do
    expect(PidController::VERSION).not_to be nil
  end

  describe '<<' do
    context 'proportion only' do
      let(:kp) { 2.0 }
      it 'returns output proportional to the measurement' do
        expect(subject << 10).to eq(180.0)
        expect(subject << 100).to eq(0.0)
        expect(subject << 150).to eq(-100.0)
      end
    end

    context 'integral only' do
      let(:ki) { 2.0 }
      it 'tracks the errors over time' do
        expect(subject << 10).to eq(0.0)
        expect(subject << 10).to eq(180.0)
        expect(subject << 100).to eq(180.0)
        expect(subject << 100).to eq(180.0)
        expect(subject << 150).to eq(80.0)
        expect(subject << 150).to eq(-20.0)
      end
    end

    context 'derivative only' do
      let(:kd) { 2.0 }
      it 'tracks the change of the measurement' do
        expect(subject << 10).to eq(0.0)
        expect(subject << 100).to eq(-180.0)
        expect(subject << 75).to eq(50.0)
        expect(subject << 75).to eq(0.0)
      end
    end

    context 'all terms' do
      let(:kp) { 1.0 }
      let(:ki) { 1.0 }
      let(:kd) { 0.1 }
      specify do
        expect(subject << 10).to eq(90.0)
        expect(subject << 50).to eq(96.0)
        expect(subject << 110).to eq(24.0)
        expect(subject << 100).to eq(41.0)
        expect(subject << 100).to eq(40.0)
        expect(subject << 100).to eq(40.0)
      end
    end
  end

  describe '#output' do
    context 'without any measurements' do
      specify do
        expect(subject.output).to eq(0.0)
      end
    end
  end

  context 'with output bounds' do
    subject { PidController.new(setpoint: 100.0, kp: 100.0, output_min: 0.0, output_max: 1000.0) }
    it 'checks output_min' do
      expect(subject << 1000).to eq(0.0)
    end
    it 'checks output_max' do
      expect(subject << -1000).to eq(1000.0)
    end
  end

  context 'with integral bounds' do
    subject { PidController.new(setpoint: 100.0, kp: 0.0, ki: 100.0, integral_min: 0.0, integral_max: 1000.0) }
    it 'checks integral_min' do
      expect(subject << 1000).to eq(0.0)
      expect(subject << 1000).to eq(0.0)
      expect(subject << 1000).to eq(0.0)
    end
    it 'checks integral_max' do
      expect(subject << -1000).to eq(0.0)
      expect(subject << -1000).to eq(100_000.0)
      expect(subject << -1000).to eq(100_000.0)
    end
  end
end
