return {
	{
		'iberianpig/tig-explorer.vim',
		config = function()
			vim.keymap.set('n', '<leader>ht', function()
				-- Rediriger la sortie pour éviter les messages affichés par Neovim
				vim.cmd('silent! call feedkeys(":TigBlame\\<CR>", "n")')
			end, { desc = 'git [t]ig blame' })
		end,
	},
}
