# PidController

This is a Ruby implementation of a [PID Controller](https://en.wikipedia.org/wiki/PID_controller). A PID controller is a feedback system that is configured with a target setpoint, can read measurements of the system to see how close we are to the setpoint, and will omit an output. Every day examples include:

- Cruise control
- Thermostats
- Quadcopters (appearently, because they predominate search results)
- Database load (yay! This is why the purpose I'm actually writing this for).

## Usage

I mentioned databases, so here's an example of how we can prevent a low priority task (e.g. bulk deletion) from contending with customer traffic:

```ruby
sensor = MySQLSensor.new # Use your imagination
controller = PIDController.new(setpoint: 60.0, kp: 5.0, ki: 1.0, kd: 0.1)

Event.where(account_id: account_id).in_batches do |relation|
  relation.delete_all
  backoff = controller << sensor.cpu_utilization
  sleep backoff if backoff > 0
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gabetax/pid_controller.
