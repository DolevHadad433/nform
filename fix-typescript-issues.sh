#!/bin/bash

# Fix TypeScript issues in Angular 16 upgrade

# Fix Operator '>=' issues in form-proxy.ts
sed -i '' 's/if (property >= target.length) {/if (Number(property) >= target.length) {/g' libs/nform/src/lib/nform/form-proxy.ts

# Fix property declarations in directives and components by adding initializers

# Fix nform-override.directive.ts
sed -i '' 's/@Input('\''nFormOverride'\'') controlName: string | string\[\];/@Input('\''nFormOverride'\'') controlName: string | string\[\] = null!;/g' libs/nform/src/lib/directives/nform-override.directive.ts
sed -i '' 's/@Input('\''nFormOverrideVType'\'') vType: keyof FormElementType | Array<keyof FormElementType>;/@Input('\''nFormOverrideVType'\'') vType: keyof FormElementType | Array<keyof FormElementType> = null!;/g' libs/nform/src/lib/directives/nform-override.directive.ts

# Fix nform-control-outlet.directive.ts
sed -i '' 's/@Input('\''nformControlOutlet'\'') controlName: string | string\[\];/@Input('\''nformControlOutlet'\'') controlName: string | string\[\] = null!;/g' libs/nform/src/lib/directives/nform-control-outlet.directive.ts
sed -i '' 's/@Input('\''nformControlOutletVType'\'') vType: keyof FormElementType | Array<keyof FormElementType>;/@Input('\''nformControlOutletVType'\'') vType: keyof FormElementType | Array<keyof FormElementType> = null!;/g' libs/nform/src/lib/directives/nform-control-outlet.directive.ts

# Fix isObservable<void> type argument issue
sed -i '' 's/isObservable<void>/isObservable/g' libs/nform/src/lib/events/before-render-event-handler.ts

# Fix nform-array.component.ts
sed -i '' 's/@Input() nFormCmp: NFormComponent;/@Input() nFormCmp: NFormComponent = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.component.ts
sed -i '' 's/@Input() fArray: FormArray;/@Input() fArray: FormArray = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.component.ts
sed -i '' 's/@Input() fGroup: FormGroup;/@Input() fGroup: FormGroup = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.component.ts
sed -i '' 's/@Input() item: NFormRecordRef;/@Input() item: NFormRecordRef = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.component.ts
sed -i '' 's/@Input() nForm: NForm<any>;/@Input() nForm: NForm<any> = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.component.ts

# Fix nform-array.directive.ts
sed -i '' 's/@Input('\''nFormArrayNFormCmp'\'') nFormCmp: NFormComponent;/@Input('\''nFormArrayNFormCmp'\'') nFormCmp: NFormComponent = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.directive.ts
sed -i '' 's/@Input('\''nFormArrayFArray'\'') fArray: FormArray;/@Input('\''nFormArrayFArray'\'') fArray: FormArray = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.directive.ts
sed -i '' 's/@Input('\''nFormArrayFGroup'\'') fGroup: FormGroup;/@Input('\''nFormArrayFGroup'\'') fGroup: FormGroup = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.directive.ts
sed -i '' 's/@Input('\''nFormArrayItem'\'') item: NFormRecordRef;/@Input('\''nFormArrayItem'\'') item: NFormRecordRef = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.directive.ts
sed -i '' 's/@Input('\''nFormArrayNForm'\'') nForm: NForm<any>;/@Input('\''nFormArrayNForm'\'') nForm: NForm<any> = null!;/g' libs/nform/src/lib/components/nform-array/nform-array.directive.ts

# Fix nform-pin.component.ts
sed -i '' 's/@Input() controlName: string | string\[\];/@Input() controlName: string | string\[\] = null!;/g' libs/nform/src/lib/components/nform-pin/nform-pin.component.ts

echo "Fixed TypeScript issues in nform library for Angular 16 compatibility"
