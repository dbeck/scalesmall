exclude = if Node.alive?, do: [], else: [distributed: true]

ExUnit.start(exclude: exclude)
ExUnit.configure(capture_log: true)

#  res = :gen_udp.open(9982, [:binary, active: :false, add_membership: {{224,0,0,1}, {0,0,0,0}}, multicast_if: {224,0,0,1}, multicast_loop: false, multicast_ttl: 4, reuseaddr: true])