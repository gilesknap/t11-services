#!/usr/bin/env bash

# Copier preserves these links from services-template-helm.  A recursive copy
# or an in-place editing tool can accidentally replace them with dereferenced
# files/directories, after which `copier update` cannot render the links.

set -u

failed=0

check_link() {
    local path=$1
    local expected=$2
    local actual

    if [[ ! -L "${path}" ]]; then
        echo "${path}: expected symlink -> ${expected}" >&2
        failed=1
        return
    fi

    actual=$(readlink "${path}")
    if [[ "${actual}" != "${expected}" ]]; then
        echo "${path}: expected symlink -> ${expected}, found -> ${actual}" >&2
        failed=1
    fi
}

# Skeletons rendered directly by the Copier template.
check_link services/.fastcs_ioc_template/Chart.yaml ../../.helm-shared/Chart.yaml
check_link services/.fastcs_ioc_template/templates ../../.helm-shared/templates
check_link services/.ioc_template/Chart.yaml ../../.helm-shared/Chart.yaml
check_link services/.ioc_template/templates ../../.helm-shared/templates
check_link services/.legacy_ioc_template/Chart.yaml ../../.helm-shared/LegacyChart.yaml

# Concrete IOC charts are linked to the same boilerplate by the template's
# migration.  Inspecting Chart.yaml also catches newly added IOC instances.
for chart in services/*/Chart.yaml; do
    [[ -e "${chart}" ]] || continue
    grep -qE '^[[:space:]]*-[[:space:]]+name:[[:space:]]+ioc-instance[[:space:]]*$' "${chart}" || continue
    service_dir=${chart%/Chart.yaml}
    check_link "${chart}" ../../.helm-shared/Chart.yaml
    check_link "${service_dir}/templates" ../../.helm-shared/templates
done

if (( failed )); then
    echo "Shared Helm links were materialized or changed; restore them before running Copier." >&2
fi

exit "${failed}"
