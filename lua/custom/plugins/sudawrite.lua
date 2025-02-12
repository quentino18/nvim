return {
	{
		'lambdalisue/suda.vim',
		opts = {},
		config = function()
			vim.api.nvim_create_user_command('W', 'SudaWrite', { desc = "Write as sudoer"})
		end
	},
}
