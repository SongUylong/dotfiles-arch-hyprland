-- Define extended prompts
local prompts = {
  -- Code related
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",
  SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",
  Complexity = "Explain the time and space complexity of this function.",
  Security = "Identify any potential security issues in this code.",
  RegexExplain = "Explain what this regular expression does.",

  -- Text related
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",
  Translate = "Translate the following text to English.",

  -- Git
  Commit = {
    prompt = '> #git:staged\n\nWrite commit message with commitizen convention. Write clear, informative commit messages that explain the "what" and "why" behind changes, not just the "how".',
  },
}

return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim" },
      { "folke/which-key.nvim", optional = true },
      { "nvim-treesitter/nvim-treesitter", optional = true },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "copilot-chat" },
        opts = {
          file_types = { "markdown", "copilot-chat" },
        },
      },
    },
    event = "VeryLazy",
    opts = {
      prompts = prompts,
      model = "gpt-4", -- or claude, gemini, etc.
      system_prompt = "You are an expert software engineer. Provide clean, accurate answers and follow best practices.",
      question_header = "  " .. (vim.env.USER or "User"),
      answer_header = "  Copilot",
      error_header = "  Error",
      mappings = {
        complete = { insert = "<Tab>", detail = "Use @<Tab> or /<Tab>" },
        close = { normal = "q", insert = "<C-c>" },
        reset = { normal = "<C-x>", insert = "<C-x>" },
        submit_prompt = { normal = "<CR>", insert = "<C-CR>" },
        accept_diff = { normal = "<C-y>", insert = "<C-y>" },
        show_help = { normal = "g?" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      chat.setup(opts)
      vim.api.nvim_create_user_command("CopilotChatVisual", function()
        local question = vim.fn.input("Ask Copilot (Visual): ")
        if question == "" then
          return
        end
        require("CopilotChat").ask(question, {
          selection = require("CopilotChat.select").visual,
        })
      end, { range = true })
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, {
          selection = function(source)
            return select.buffer(source)
          end,
        })
      end, { nargs = "*", range = true })

      -- Auto set markdown filetype
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        group = vim.api.nvim_create_augroup("CopilotChatSettings", { clear = true }),
        callback = function(args)
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true
          vim.opt_local.wrap = true
          vim.schedule(function()
            if vim.bo[args.buf].filetype == "copilot-chat" or vim.bo[args.buf].filetype == "" then
              vim.bo[args.buf].filetype = "markdown"
            end
          end)
        end,
      })
    end,

    keys = {
      -- Prompt Picker (normal and visual)
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({ selection = require("CopilotChat.select").visual })
        end,
        mode = "x",
        desc = "Prompt Picker (Visual)",
      },

      -- Predefined Prompt Actions
      { "<leader>ae", "<cmd>CopilotChatExplain<CR>", desc = "Explain Code" },
      { "<leader>at", "<cmd>CopilotChatTests<CR>", desc = "Generate Tests" },
      { "<leader>ar", "<cmd>CopilotChatReview<CR>", desc = "Review Code" },
      { "<leader>aR", "<cmd>CopilotChatRefactor<CR>", desc = "Refactor Code" },
      { "<leader>an", "<cmd>CopilotChatBetterNamings<CR>", desc = "Better Naming" },
      { "<leader>af", "<cmd>CopilotChatFixError<CR>", desc = "Fix Diagnostic" },

      -- Visual Chat Commands
      { "<leader>av", ":<C-u>CopilotChatVisual<CR>", mode = "x", desc = "Visual Chat (ask prompt)" },
      -- Input/Freeform
      {
        "<leader>ai",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "Ask Copilot (Input)",
      },

      -- Buffer Context
      {
        "<leader>ab",
        function()
          local input = vim.fn.input("Quick Chat (Buffer): ")
          if input ~= "" then
            vim.cmd("CopilotChatBuffer " .. input)
          end
        end,
        desc = "Ask About Buffer",
      },

      -- Git commit
      { "<leader>am", "<cmd>CopilotChatCommit<CR>", desc = "Commit Message (Staged)" },

      -- Utility
      { "<leader>aa", "<cmd>CopilotChatAgents<CR>", desc = "Select Agent" },
      { "<leader>a?", "<cmd>CopilotChatModels<CR>", desc = "Select Model" },
      { "<leader>al", "<cmd>CopilotChatReset<CR>", desc = "Clear Chat" },
      { "<leader>aw", "<cmd>CopilotChatToggle<CR>", desc = "Toggle Chat Window" },
    },
  },
}
