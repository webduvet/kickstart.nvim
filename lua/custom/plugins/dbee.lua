-- Database client (Postgres, MySQL, SQLite, ...). Unlike vim-dadbod-ssh,
-- nvim-dbee has no built-in SSH tunneling, so this file opens plain
-- `ssh -N -L` tunnels itself, in code, before registering connections --
-- no :DbeeTunnel typing required. Add/edit connections in `connections`
-- below; each entry can carry an optional `tunnel` table, and tunnels
-- sharing the same local_port are deduped and opened once, at startup.
--
-- Keep credentials out of this file (it's pushed to a public repo) --
-- pull them from the environment instead, e.g. in ~/.zshrc:
--   export PROD_DB_USER=... PROD_DB_PASS=...
-- and reference them below with os.getenv(...).

---@class DbeeTunnelSpec
---@field ssh_host string
---@field local_port integer
---@field remote_host string
---@field remote_port integer
---@field identity_file? string Private key matching the certificate (e.g. '~/.ssh/id_ed25519')
---@field cert_file? string Signed cert, only needed if it isn't '<identity_file>-cert.pub'

---@class DbeeConnectionSpec
---@field name string
---@field type string
---@field url string
---@field tunnel? DbeeTunnelSpec

---@type DbeeConnectionSpec[]
local connections = {
  -- {
  --   name = 'Prod (via bastion)',
  --   type = 'postgres',
  --   tunnel = { ssh_host = 'bastion', local_port = 5433, remote_host = 'db-internal.prod', remote_port = 5432 },
  --   url = ('postgres://%s:%s@localhost:5433/mydb?sslmode=disable'):format(
  --     os.getenv 'PROD_DB_USER' or '',
  --     os.getenv 'PROD_DB_PASS' or ''
  --   ),
  -- },
  -- {
  --   name = 'Staging (via bastion, same tunnel host reused on a different port)',
  --   type = 'postgres',
  --   tunnel = { ssh_host = 'bastion', local_port = 5434, remote_host = 'db-internal.staging', remote_port = 5432 },
  --   url = ('postgres://%s:%s@localhost:5434/mydb?sslmode=disable'):format(
  --     os.getenv 'STAGING_DB_USER' or '',
  --     os.getenv 'STAGING_DB_PASS' or ''
  --   ),
  -- },
  -- {
  --   name = 'Local dev (no tunnel)',
  --   type = 'postgres',
  --   url = 'postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable',
  -- },
  -- -- Bastion using a .pem private key (e.g. an AWS EC2 key pair). A .pem
  -- -- here is just a plain private key, not a signed SSH certificate, so
  -- -- `identity_file` alone is all that's needed -- leave `cert_file` unset.
  -- -- `chmod 400` the .pem first or ssh will refuse it for being world/group
  -- -- readable.
  {
    name = 'UAT-settle',
    type = 'postgres',
    tunnel = {
      ssh_host = 'jumpuser@99.80.108.58', -- or a Host alias from ~/.ssh/config
      local_port = 5435,
      remote_host = 'infinite-uat-settle-db.cipazza3vsci.eu-west-1.rds.amazonaws.com',
      remote_port = 5432,
      identity_file = '~/infinite/certs/DB_access/Uat_DbJumpboxUserKeypair.pem',
    },
    url = ('postgres://%s:%s@localhost:5435/settle_uat?sslmode=disable'):format(
      os.getenv 'UAT_DB_USER' or 'settle_qa_user',
      os.getenv 'UAT_DB_PASS' or ''
    ),
  },
}

local tunnel_jobs = {} ---@type table<integer, integer>

---@param t DbeeTunnelSpec
local function open_tunnel(t)
  if tunnel_jobs[t.local_port] then return end

  local args = { 'ssh', '-N', '-L', ('%d:%s:%d'):format(t.local_port, t.remote_host, t.remote_port) }
  if t.identity_file then
    table.insert(args, '-i')
    table.insert(args, vim.fn.expand(t.identity_file))
    -- Without this, ssh still offers any keys an ssh-agent holds before
    -- trying identity_file, which trips "too many authentication failures"
    -- on bastions with strict MaxAuthTries.
    table.insert(args, '-o')
    table.insert(args, 'IdentitiesOnly=yes')
  end
  if t.cert_file then
    table.insert(args, '-o')
    table.insert(args, 'CertificateFile=' .. vim.fn.expand(t.cert_file))
  end
  table.insert(args, t.ssh_host)

  local job = vim.fn.jobstart(
    args,
    {
      on_stderr = function(_, data)
        local msg = table.concat(data, '\n'):gsub('%s+$', '')
        if msg ~= '' then vim.notify(('[dbee tunnel %s] %s'):format(t.ssh_host, msg), vim.log.levels.WARN) end
      end,
      on_exit = function() tunnel_jobs[t.local_port] = nil end,
    }
  )
  if job <= 0 then
    vim.notify(('Failed to start ssh tunnel to %s (local port %d)'):format(t.ssh_host, t.local_port), vim.log.levels.ERROR)
    return
  end
  tunnel_jobs[t.local_port] = job
end

local function open_all_tunnels()
  for _, conn in ipairs(connections) do
    if conn.tunnel then open_tunnel(conn.tunnel) end
  end
  -- Give ssh a beat to actually establish the forwards before dbee's
  -- connections (pointed at localhost:<port>) get used. Cheap and good
  -- enough in practice; if a first query still races the handshake, just
  -- retry it.
  if next(tunnel_jobs) then vim.wait(600) end
end

vim.api.nvim_create_autocmd('VimLeavePre', {
  desc = 'Close nvim-dbee ssh tunnels',
  callback = function()
    for _, job in pairs(tunnel_jobs) do
      vim.fn.jobstop(job)
    end
  end,
})

-- Ad-hoc tunnels/connections not worth adding to the list above can still
-- go through these, same as before.
vim.api.nvim_create_user_command('DbeeTunnel', function(cmd)
  local ssh_host, local_port, remote_host, remote_port = unpack(vim.split(cmd.args, '%s+'))
  if not (ssh_host and local_port and remote_host and remote_port) then
    vim.notify('Usage: :DbeeTunnel <ssh_host> <local_port> <remote_host> <remote_port>', vim.log.levels.ERROR)
    return
  end
  open_tunnel { ssh_host = ssh_host, local_port = tonumber(local_port), remote_host = remote_host, remote_port = tonumber(remote_port) }
  vim.notify(('SSH tunnel up: localhost:%s -> %s:%s via %s'):format(local_port, remote_host, remote_port, ssh_host))
end, { nargs = '*', desc = 'Open SSH tunnel for nvim-dbee: host local_port remote_host remote_port' })

vim.api.nvim_create_user_command('DbeeTunnelStop', function(cmd)
  local local_port = tonumber(cmd.args)
  local job = tunnel_jobs[local_port]
  if not job then
    vim.notify('No tracked tunnel on localhost:' .. cmd.args, vim.log.levels.WARN)
    return
  end
  vim.fn.jobstop(job)
  tunnel_jobs[local_port] = nil
  vim.notify('Stopped SSH tunnel on localhost:' .. cmd.args)
end, { nargs = 1, desc = 'Stop an SSH tunnel opened by :DbeeTunnel (local_port)' })

vim.keymap.set('n', '<leader>Du', ':Dbee toggle<cr>', { desc = '[U]I toggle (nvim-dbee)' })

require('which-key').add {
  { '<leader>D', group = 'Database' },
}

return {
  'kndndrj/nvim-dbee',
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'Dbee',
  build = function() require('dbee').install() end,
  config = function()
    open_all_tunnels()

    local memory_connections = vim.tbl_map(function(conn)
      return { name = conn.name, type = conn.type, url = conn.url }
    end, connections)

    require('dbee').setup {
      sources = {
        require('dbee.sources').MemorySource:new(memory_connections),
        require('dbee.sources').FileSource:new(vim.fn.stdpath 'cache' .. '/dbee/persistence.json'),
      },
    }
  end,
}
