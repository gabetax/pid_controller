require 'pid_controller/version'

# https://en.wikipedia.org/wiki/PID_controller
class PidController
  attr_accessor :setpoint, :kp, :ki, :kd

  def initialize(
    setpoint:,
    kp: 1.0,
    ki: 1.0,
    kd: 1.0,
    integral_min: nil,
    integral_max: nil,
    output_min: nil,
    output_max: nil
  )
    @setpoint = setpoint
    @kp = kp
    @ki = ki
    @kd = kd
    # Prevents https://en.wikipedia.org/wiki/Integral_windup via bounds
    @integral_min = integral_min || -Float::INFINITY
    @integral_max = integral_max || Float::INFINITY
    @output_min = output_min || -Float::INFINITY
    @output_max = output_max || Float::INFINITY
    @integral   = 0.0
    @derivative = 0.0
    @last_error  = nil
    @last_update = nil
  end

  unless defined?(0.clamp)
    # Comparable#clamp is introduced in Ruby 2.4
    module NumericClamp
      # I'd refine Comparable itself, but older Rubies can't refine modules
      refine Numeric do
        def clamp(min, max)
          [min, [max, self].min].max
        end
      end
    end
    using NumericClamp
  end

  def update(measurement)
    now = clock_time
    dt = if @last_update
           now - @last_update
         else
           0.0
         end
    @last_update = now
    update_with_duration(measurement, dt)
  end

  alias << update

  def update_with_duration(measurement, dt)
    error = setpoint - measurement.to_f

    if dt > 0.0
      @integral = (@integral + error * dt).clamp(@integral_min, @integral_max)
      @derivative = (error - @last_error) / dt if @last_error
    end

    @last_error = error

    output
  end

  def output
    (p_term + i_term + d_term).clamp(@output_min, @output_max)
  end

  def p_term
    kp * (@last_error || 0.0)
  end

  def i_term
    ki * @integral
  end

  def d_term
    kd * @derivative
  end

  # Read the monotonic clock. It avoid horrors of leap seconds and NTP.
  def clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
