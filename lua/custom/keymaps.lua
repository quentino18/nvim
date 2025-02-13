local ls = require("luasnip")
local snip = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

-- Fonction pour récupérer l'utilisateur
local function get_user()
    return vim.g.user or os.getenv("USER") or os.getenv("USERNAME")
end

vim.keymap.set('n', '<F1>', ':tabnew<CR>', {desc = 'Create new tab'})
vim.keymap.set('n', '<F2>', ':tabprevious<CR>', {desc = 'Goto previous tab'})
vim.keymap.set('n', '<F3>', ':tabnext<CR>', {desc = 'Goto new tab'})
vim.keymap.set('n', '<F4>', ':e %:p:s,.h$,.X123X,:s,.c$,.h,:s,.X123X$,.c,<CR>', {desc = 'Open associated .h file'})
vim.keymap.set('n', '<F5>', ':e %:p:s,.private.h$,.X123X,:s,.c$,.private.h,:s,.X123X$,.c,<CR>', {desc = 'Open associated .private.h file'})
vim.keymap.set('n', '<F6>', ':e %:p:s,.protected.h$,.X123X,:s,.c$,.protected.h,:s,.X123X$,.c,<CR>', {desc = 'Open associated .protected.h file'})

vim.keymap.set('n', '<F8>', ':%s#\\<<c-r><c-w>\\>#<c-r><c-w>#gc', {desc = 'Open associated .protected.h file'})
vim.keymap.set("n", "<F12>", ":Neotree toggle<CR>", { desc = "Open/Close file tree" })

vim.keymap.set('v', '<leader>y', '"+y', {noremap = true, desc = 'Copy to clipboard (visual)'})
vim.keymap.set('n', '<leader>y', '"+y', {noremap = true, desc = 'Copy to clipboard (normal)'})

vim.keymap.set('n', '<leader>e', ':Explore<CR>', {desc = 'Explore'})

-- Remapper "=" pour indenter et supprimer les espaces blancs en fin de ligne sur une sélection visuelle
vim.api.nvim_set_keymap('x', '=', [[:<C-U>normal! gv=]<CR>:silent '<,'>s/\s\+$//ge<CR>]], { noremap = true, silent = true })

-- COPY PASTE MODE--------------------------------------------------------
-- Toggle between number and relativenumber
function ToggleNumber()
    if vim.wo.relativenumber then
        vim.wo.relativenumber = false
        vim.wo.number = true
    else
        vim.wo.relativenumber = true
    end
end

vim.api.nvim_set_keymap('n', '<leader>n', ':lua ToggleNumber()<CR>', { noremap = true, silent = true })

-- Toggle between Normal and copy mode (disabling Gitsigns & nvim-lint)
function ToggleCopyPaste()
	local ok, indent_blankline = pcall(require, 'ibl') -- Vérifie si indent-blankline est installé

	if vim.o.paste then
		vim.o.paste = false
		vim.wo.number = true
		vim.wo.list = true

		-- Réactiver Gitsigns, nvim-lint et indent-blankline
		require('gitsigns').attach()
		vim.diagnostic.enable()

		if ok then
			indent_blankline.setup({ enabled = true }) -- Réactive les barres d'indentation
		end
	else
		vim.o.paste = true
		vim.wo.number = false
		vim.wo.list = false

		-- Désactiver Gitsigns, nvim-lint, diagnostics et indent-blankline
		require('gitsigns').detach()
		vim.diagnostic.disable()

		if ok then
			indent_blankline.setup({ enabled = false }) -- Désactive les barres d'indentation
		end
	end
end

vim.api.nvim_set_keymap('n', '<leader>p', ':lua ToggleCopyPaste()<CR>', { noremap = true, silent = true })

-- Remplacer les espaces insécables par des espaces lors de l'enregistrement
vim.api.nvim_create_autocmd("BufWrite", {
pattern = "*",
	command = ":%s/\\%xa0/ /ge",
})

-- Supprimer les espaces blancs en fin de ligne sur certains types de fichiers
vim.api.nvim_create_autocmd("BufWrite", {
	pattern = { "*.c", "*.h", "*.sh", "*.py", "*.rst" },
	command = ":%s/\\s\\+$//ge",
})

-- COMMON DIE METHODS--------------------------------------------------------
vim.keymap.set("n", "<leader>cad", ":!bash /produits/".. vim.g.user .."/cmd_check.sh -c %<CR>", {desc = 'Commmon die check', noremap = true, silent = true })
local function find_return_and_func_value(lines)

	local last_line = lines[#lines] or ""
	local ret, func = last_line:match("^%s*([%w_]+)%s*=%s*([%w_]+)%s*%(")

	if not ret then
		ret = "ret"
	end
	if not func then
		func = "function"
	end
	return ret, func
end

local function get_last_common_die_value(lines)
	-- Parcourir les lignes de bas en haut
	for idx = #lines, 1, -1 do
		-- Vérifier si la ligne contient un prototype de fonction C (detection de ligne commençant en colonne 0)
		local match = lines[idx]:match("^[^%s]")
		if match then
			print(string.format("prototype found , line: %s", lines[idx]))
			-- Si une définition de fonction est trouvée, retourner la dernière valeur d'erreur trouvée
			return -1
		end

		-- Recherche un nombre négatif (-X) dans le premier, deuxième ou troisième argument
		local match_val = lines[idx]:match("%s*common_die[_%w]*%s*%(%s*(-%d+)")              -- Premier argument
			       or lines[idx]:match("%s*common_die[_%w]*%s*%([^,]*,%s*(-%d+)")        -- Deuxième argument
		               or lines[idx]:match("%s*common_die[_%w]*%s*%([^,]*,[^,]*,%s*(-%d+)")  -- Troisième argument

		-- Afficher la valeur trouvée et la ligne correspondante (utile pour déboguer)
		if match_val then
			print(string.format("Found value: %s on line: %s", match_val, lines[idx]))
			-- Retourner la valeur moins 1
			return tonumber(match_val) - 1
		end
	end

	-- Retourner la valeur par défaut si aucune valeur n'a été trouvée
	return -1
end


local function common_die()
	-- Récupérer les lignes du buffer
	local cursor_pos = vim.api.nvim_win_get_cursor(0)[1] - 1
	local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_pos, false)

	-- Trouver la dernière valeur de `common_die_*`
	local last_error_val = get_last_common_die_value(lines)

	-- Générer la ligne `common_die_zero`
	return { string.format('%d',last_error_val) }
end

local function common_die_zero()
	-- Récupérer les lignes du buffer
	local cursor_pos = vim.api.nvim_win_get_cursor(0)[1] - 1
	local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_pos, false)

	local ret, func = find_return_and_func_value(lines)
	if not (ret and func) then
		print("Aucune correspondance trouvée")
		return { 'common_die_zero( var, -1, " Error unknown_func return %d", var);' }
	end

	-- Trouver la dernière valeur de `common_die_*`
	local last_error_val = get_last_common_die_value(lines)

	-- Générer la ligne `common_die_zero`
	return { string.format('common_die_zero( %s, %d, " Error %s return %%d", %s);', ret, last_error_val, func, ret) }
end

local function common_die_null()
	-- Récupérer les lignes du buffer
	local cursor_pos = vim.api.nvim_win_get_cursor(0)[1] - 1
	local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_pos, false)

	local ret, func = find_return_and_func_value(lines)
	if not (ret and func) then
		print("Aucune correspondance trouvée")
		return { 'common_die_null( ret, -1, "Error unknown function null pointer");' }
	end

	-- Trouver la dernière valeur de `common_die_*`
	local last_error_val = get_last_common_die_value(lines)

	-- Générer la ligne `common_die_null`
	return { string.format('common_die_null( %s, %d, "Error %s null pointer");', ret, last_error_val, func) }
end

local function common_die_snprintf()
	-- Récupérer les lignes du buffer
	local cursor_pos = vim.api.nvim_win_get_cursor(0)[1] - 1
	local lines = vim.api.nvim_buf_get_lines(0, 0, cursor_pos, false)

	local ret, func = find_return_and_func_value(lines)
	if not (ret and func) then
		print("Aucune correspondance trouvée")
		return { 'common_die_snprintf( var, -1, sizeof(cmd), " Error snprintf return %d", var);' }
	end

	-- Trouver la dernière valeur de `common_die_*`
	local last_error_val = get_last_common_die_value(lines)

	-- Générer la ligne `common_die_zero`
	return { string.format('common_die_snprintf( %s, %d, sizeof(cmd), " Error snprintf return %%d", %s);', ret, last_error_val, ret) }
end



--- Schiller snippets
ls.add_snippets("c", {
	snip({trig = "ptf",  dscr = "STD Debug printf"},    { t'printf("[',f(get_user, {}),t'_debug] %s:%d: ',               i(1, ''), t' %d\\n", __FUNCTION__, __LINE__, ',         i(2, 'var'), t');', i(0)}),
	snip({trig = "bptf", dscr = "BLUE Debug printf"},   { t'printf("\\x1B[1;44m[',f(get_user, {}),t'_debug] %s:%d: ',    i(1, ''), t' %d\\x1B[0m\\n", __FUNCTION__, __LINE__, ', i(2, 'var'), t');', i(0)}),
	snip({trig = "rptf", dscr = "RED Debug printf"},    { t'printf("\\x1B[1;41m[',f(get_user, {}),t'_debug] %s:%d: ',    i(1, ''), t' %d\\x1B[0m\\n", __FUNCTION__, __LINE__, ', i(2, 'var'), t');', i(0)}),
	snip({trig = "gptf", dscr = "GREEN Debug printf"},  { t'printf("\\x1B[1;42;30m[',f(get_user, {}),t'_debug] %s:%d: ', i(1, ''), t' %d\\x1B[0m\\n", __FUNCTION__, __LINE__, ', i(2, 'var'), t');', i(0)}),
	snip({trig = "yptf", dscr = "YELLOW Debug printf"}, { t'printf("\\x1B[1;43;30m[',f(get_user, {}),t'_debug] %s:%d: ', i(1, ''), t' %d\\x1B[0m\\n", __FUNCTION__, __LINE__, ', i(2, 'var'), t');', i(0)}),
	snip({trig = "vptf", dscr = "PURPLE Debug printf"}, { t'printf("\\x1B[1;35m[',f(get_user, {}),t'_debug] %s:%d: ',           i(1, ''), t' %d\\x1B[0m\\n", __FUNCTION__, __LINE__, ', i(2, 'var'), t');', i(0)}),
	snip({trig = "wptf", dscr = "WHITE Debug printf"},  { t'printf("\\x1B[1;100m[',f(get_user, {}),t'_debug] %s:%d: ',          i(1, ''), t' %d\\x1B[0m\\n", __FUNCTION__, __LINE__, ', i(2, 'var'), t');', i(0)}),

	snip({trig = "cd",  dscr = "common_die"}, { t'common_die( ', f(common_die), t', "Error ', i(1, 'function'),t'");'}),
	snip({trig = "cdz" , dscr = "common_die_zero"}, f(common_die_zero)),
	snip({trig = "cdn" , dscr = "common_die_null"}, f(common_die_null)),
	snip({trig = "cds" , dscr = "common_die_snprintf"}, f(common_die_snprintf)),

})
