// Tripwire for the pi screen rules — not a test of pi.
//
// The screens below are typed transcriptions of live panes (tuios 0.12.1, pi 1.5.0,
// rpiv-ask-user-question 2.15.0, at split width); nothing here starts pi or renders
// a view. Feeding them to tuios' own matcher proves only that the manifest still
// resolves them to the same rule and actions: no mistyped literal, no reordered
// priority, no new rule shadowing an old one. Worth catching, because the manifest
// is hand-edited and loads happily when a rule matches nothing.
//
// It cannot catch a reworded hint — the real pane stops matching while these keep
// passing. Read a live pane for that, and refresh a fixture only from one:
//
//	tuios explain-agent-screen --harness pi -w <pane> --json  # `missing`: the strings that did not match
//	tuios peek-prompt -w <pane> --json                        # `actions`: what the Inbox may press
//
// Copied into a tuios tree by mise-tasks/test/tuios-pi-rules: the matcher is internal.

package harness

import (
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
)

// Each fixture is one state of a dialog as the pane draws it. want is the
// priority of the rule that must match, or -1 when no rule may match at all.
func TestPiRules(t *testing.T) {
	manifest := os.Getenv("PI_MANIFEST")
	if manifest == "" {
		t.Fatal("PI_MANIFEST is not set")
	}
	r, errs := Load(filepath.Dir(manifest))
	for _, e := range errs {
		t.Fatalf("load %s: %v", e.Source, e.Err)
	}
	m := r.Lookup("pi")
	if m == nil {
		t.Fatal("the manifest does not replace pi")
	}

	border := strings.Repeat("─", 60)
	status := "8.4%/32k (auto)"

	cases := []struct {
		name    string
		screen  []string
		want    int
		actions []string
	}{
		{"rpiv question, row list", []string{
			" Which task are we planning right now?", "❯ 1. Bug fix", "  2. New feature",
			"  3. Refactor", "  4. Type something.", border,
			" Enter to select · ↑/↓ to navigate · n to add notes · Esc to cancel · Ctrl+] to collapse", status,
		}, 129, []string{"choose", "deny"}},

		// The footer used to have to carry "Esc to cancel" to be read; the two hints
		// that identify a resting question tab sit earlier, so a clipped footer is
		// still answerable.
		{"rpiv question, footer clipped before Esc", []string{
			" Which task are we planning right now?", "❯ 1. Bug fix", "  2. New feature", border,
			" Enter to select · ↑/↓ to navigate · n to add notes · Es…", status,
		}, 129, []string{"choose", "deny"}},

		{"rpiv checkbox", []string{
			" Which checks should run?", "❯ 1. [ ] Unit tests", "  2. [ ] Integration tests",
			"  3. [ ] Lint", "  4. [ ] Type something.", "  Submit", border,
			" Enter to select · ↑/↓ to navigate · Space to toggle · n to add notes · Esc to cancel · Ctrl+] to collapse", status,
		}, 130, []string{"deny"}},

		{"rpiv Submit tab", []string{
			" Review your answers", "❯ 1. Submit answers", "  2. Cancel", border,
			" Enter to select · ↑/↓ to navigate · n to add a note · Esc to cancel", status,
		}, 128, []string{"approve", "deny"}},

		{"rpiv text row", []string{
			" Which task are we planning right now?", "❯ 4. dr", "  1. Bug fix", border,
			" Enter to select · ↑/↓ to navigate · Esc to cancel · Ctrl+] to collapse · Shift+Enter for newline · Ctrl+U to clear", status,
		}, 131, []string{"deny", "text"}},

		{"rpiv text row, footer clipped after Esc", []string{
			" Which task are we planning right now?", "❯ 4. dr", "  1. Bug fix", border,
			" Enter to select · ↑/↓ to navigate · Esc to cancel · Ctrl+] to coll…", status,
		}, -1, nil},

		{"rpiv two-question form, row list", []string{
			" ←  □ Task   □ Checks   ✓ Submit  →", " Which task are we planning right now?",
			"❯ 1. Bug fix", "  2. New feature", "  3. Type something.", border,
			" Enter to select · ↑/↓ to navigate · n to add notes · Tab to switch questions · Esc to cancel · Ctrl+] to collapse", status,
		}, 129, []string{"choose", "deny"}},

		{"rpiv two-question form, Submit tab", []string{
			" ←  ✓ Task   □ Checks   ✓ Submit  →", " Review your answers",
			"❯ 1. Submit answers", "  2. Cancel", border,
			" Enter to select · ↑/↓ to navigate · n to add a note · Tab to switch questions · Esc to cancel", status,
		}, 128, []string{"approve", "deny"}},

		// The line as the pane really shows it at a 117-column dialog: the typing
		// hints are cut, so only their absence identifies this state.
		{"rpiv two-question form, text row clipped", []string{
			" ←  □ Task   □ Checks   ✓ Submit  →", " Which task are we planning right now?",
			"  1. Bug fix", "  2. New feature", "❯ 3. ", border,
			" Enter to select · ↑/↓ to navigate · Tab to switch questions · Esc to cancel · Ctrl+] to collapse · Shift+Enter fo…", status,
		}, 132, []string{"deny", "text"}},

		// Same footer when clipped: a note, not an answer. Accepted, and visible in
		// the agent's pane, rather than leaving the row dead.
		{"rpiv two-question form, notes editor clipped", []string{
			" ←  □ Task   □ Checks   ✓ Submit  →", " Notes:", " first line",
			" Enter to select · ↑/↓ to navigate · Tab to switch questions · Esc to cancel · Ctrl+] to collapse · Shift+Enter fo…", status,
		}, 132, []string{"deny", "text"}},

		// A checkbox dialog is answered by ticking rows and pressing its unnumbered
		// Submit, which an answer cannot do, so the Inbox offers exactly one thing at
		// any width and in any of its states: cancel.
		{"rpiv checkbox, text row focused", []string{
			" Which checks should run?", "  1. [ ] Unit tests", "❯ 4. ", border,
			" Enter to select · ↑/↓ to navigate · Space to toggle · Esc to cancel · Ctrl+] to collapse · Shift+Enter for newline · Ctrl+U to clear", status,
		}, 130, []string{"deny"}},

		{"rpiv two-question checkbox, text row clipped", []string{
			" ←  □ Task   □ Checks   ✓ Submit  →", " Which checks should run?", "❯ 3. ", border,
			" Enter to select · ↑/↓ to navigate · Space to toggle · Tab to switch questions · Esc to cancel · Ctrl+] to collapse · Shift+Enter fo…", status,
		}, 130, []string{"deny"}},

		// Trimming the redundant literals is what keeps these working when the dialog
		// is narrow: each fixture below is a footer that has lost hints it does not
		// actually need to be identified.
		{"rpiv checkbox, footer clipped to the toggle hint", []string{
			" Which checks should run?", "❯ 1. [ ] Unit tests", border,
			" Enter to select · ↑/↓ to navigate · Space to toggle · Esc to canc…", status,
		}, 130, []string{"deny"}},

		{"rpiv one-of-N, footer clipped after the notes hint", []string{
			" Which task are we planning right now?", "❯ 1. Bug fix", border,
			" Enter to select · ↑/↓ to navigate · n to add notes · Esc…", status,
		}, 129, []string{"choose", "deny"}},

		{"pi confirm, Yes highlighted", []string{
			" Allow bash?", " Run: echo hello", " → Yes", "   No",
			" ↑↓ navigate  enter select  escape/ctrl+c cancel", status,
		}, 121, []string{"approve", "deny"}},

		{"rpiv notes editor open", []string{
			" Which task are we planning right now?", "❯ 1. Bug fix", " Notes:", border,
			" Enter to select · ↑/↓ to navigate · Esc to cancel · Ctrl+] to collapse · Shift+Enter for newline", status,
		}, -1, nil},

		{"pi input", []string{
			" Commit message", ">", " enter submit  escape/ctrl+c cancel", status,
		}, 120, []string{"deny", "text"}},

		{"pi select", []string{
			" Pick a colour", " → red", "   green", "   blue",
			" ↑↓ navigate  enter select  escape/ctrl+c cancel", status,
		}, -1, nil},

		{"pi editor", []string{
			" Describe the change", " first line", " ",
			" enter submit  shift+enter/ctrl+j newline  escape/ctrl+c cancel  ctrl+g external editor", status,
		}, -1, nil},
	}

	for _, c := range cases {
		p, ok := r.ScreenPrompt("pi", c.screen, c.screen)
		if c.want < 0 {
			if ok {
				t.Errorf("%s: a rule matched (priority %d, actions %v), want none",
					c.name, m.Screen.Rule[p.Rule].Priority, p.Actions())
			}
			continue
		}
		if !ok {
			t.Errorf("%s: no rule matched, want priority %d", c.name, c.want)
			continue
		}
		if got := m.Screen.Rule[p.Rule].Priority; got != c.want {
			t.Errorf("%s: matched priority %d, want %d", c.name, got, c.want)
		}
		got, want := p.Actions(), slices.Clone(c.actions)
		slices.Sort(got)
		slices.Sort(want)
		if !slices.Equal(got, want) {
			t.Errorf("%s: actions %v, want %v", c.name, got, want)
		}
	}
}
