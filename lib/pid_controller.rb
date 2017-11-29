require 'pid_controller/version'

# https://en.wikipedia.org/wiki/PID_controller
class PidController
  attr_accessor :setpoint, :kp, :ki, :kd

  def initialize(setpoint:, kp: 1.0, ki: 1.0, kd: 1.0)
    @setpoint = setpoint
    @kp = kp
    @ki = ki
    @kd = kd
    @integral   = 0.0
    @derivative = 0.0
    @last_error  = nil
    @last_update = nil
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
      @integral += error * dt
      @derivative = (error - @last_error) / dt
    end

    @last_error = error

    output
  end

  def output
    p_term + i_term + d_term
  end

  def p_term
    kp * @last_error
  end

  def i_term
    ki * @integral
  end

  def d_term
    kd * @derivative
  end

  def clock_time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end
end
