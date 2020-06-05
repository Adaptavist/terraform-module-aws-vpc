package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModuleCompletes(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "fixtures/default",
		NoColor: true,
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)
}
