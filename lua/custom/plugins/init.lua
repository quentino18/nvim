-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
	{	'wsdjeg/vim-fetch'},
	{	'farmergreg/vim-lastplace'},
	{
		'lfv89/vim-interestingwords',
		opts = {},
		config = function()
			vim.g.interestingWordsGUIColors = {'#2E56DB', '#8CCBEA', '#A4E57E', '#FFDB72', '#FF7272', '#FFB3FF', '#9999FF'}
		end
	},
	{
		'lambdalisue/suda.vim',
		opts = {},
		config = function()
			vim.api.nvim_create_user_command('W', 'SudaWrite', { desc = "Write as sudoer"})
		end
	},
	{
		'iberianpig/tig-explorer.vim',
		config = function()
			vim.keymap.set('n', '<leader>ht', function()
				-- Rediriger la sortie pour éviter les messages affichés par Neovim
				vim.cmd('silent! call feedkeys(":TigBlame\\<CR>", "n")')
			end, { desc = 'git [t]ig blame' })
		end,
	},
	{	'mbbill/undotree'},
	{	'powerman/vim-plugin-AnsiEsc'},
}
