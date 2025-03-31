-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
---@module 'lazy'
---@type LazySpec
return {
	{	'wsdjeg/vim-fetch'},
	{	'farmergreg/vim-lastplace'},
	{
		'ririck0/vim-interestingwords',
		opts = {},
		config = function()
			vim.g.interestingWordsGUIColors = {'#F7C873', '#8BC34A', '#00BCD4', '#FF5722', '#E91E63', '#4CAF50', '#FFEB3B', '#CDDC39', '#03A9F4', '#9C27B0', '#673AB7', '#FFC107', '#2196F3', '#795548', '#F44336', '#FF9800', '#3F51B5', '#00E676', '#FFEB3B', '#FFB74D', '#FF4081', '#8E24AA', '#00ACC1', '#00796B', '#64B5F6', '#AED581', '#B39DDB', '#D4E157', '#FF7043', '#BA68C8', '#81C784', '#F06292'}
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
	{	'preservim/tagbar'},
	{	'mbbill/undotree'},
	{	'powerman/vim-plugin-AnsiEsc'},
}
