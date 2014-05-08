require "devops_test"
require "cud_command"
class Deploy < DevopsTest

  include CudCommand

  def title
    "Deploy test (invalid queries only)"
  end

  # tests invalid queries only, valid query in client test
  def run
    all_privileges
    test_headers("deploy", "post", false)

    deploy = {
      :names => ["foo"],
      :tags => ["foo"]
    }
    test_auth("deploy", deploy)
    cnt = 0
    headers = HEADERS.clone
    headers.delete("Accept")
    st = 400
    nf_st = 404
    begin
      [{}, [], "", nil].each do |p|
        self.send_post("deploy", p, headers, st)
        d = deploy.clone
        d.delete(:tags)
        d[:names] = p
        self.send_post("deploy", d, headers, st)
        unless p.nil?
          d = deploy.clone
          d[:tags] = p
          self.send_post("deploy", d, headers, st)
        end
      end
      deploy[:tags] = nil
      self.send_post("deploy", deploy, headers, nf_st)
      deploy.delete(:tags)
      self.send_post("deploy", deploy, headers, nf_st)
      if cnt == 0
        cnt = 1
        write_only_privileges
        raise RangeError
      end
    rescue RangeError
      retry
    end

  end

end

