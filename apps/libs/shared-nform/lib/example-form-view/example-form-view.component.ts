import { debounceTime } from 'rxjs/operators';
import { Component, ContentChild, Input, SimpleChanges, ChangeDetectorRef, AfterViewInit, Inject } from '@angular/core';
import { trigger, transition, animate, style } from '@angular/animations'
import { coerceBooleanProperty } from '@angular/cdk/coercion';

import { UnRx } from '@pebula/utils';
import { ExampleViewComponent, LazyModuleStoreService, MarkdownCodeExamplesService, EXAMPLE_COMPONENTS_TOKEN } from '@pebula/apps/shared';
import { AbstractControl } from '@angular/forms';
import { NFormComponent } from '@pebula/nform';

import * as hljs from 'highlight.js';
hljs.registerLanguage('json', require(`highlight.js/lib/languages/json.js`));

@Component({
  selector: 'pbl-example-form-view',
  templateUrl: './example-form-view.component.html',
  styleUrls: ['./example-form-view.component.scss'],
  host: {
    '[class.example-style-flow]': 'exampleStyle === "flow"',
    '[class.example-style-toolbar]': '!noToolbar && exampleStyle === "toolbar"',
  },
  animations: [
    trigger('slideInOutLeft', [
      transition(':enter', [
        style({transform: 'translateX(-100%)'}),
        animate('200ms ease-in', style({transform: 'translateX(0%)'}))
      ]),
      transition(':leave', [
        animate('200ms ease-in', style({transform: 'translateX(-100%)'}))
      ])
    ]),
    trigger('slideInOutRight', [
      transition(':enter', [
        style({transform: 'translateX(200%)'}),
        animate('200ms ease-in', style({transform: 'translateX(0%)'}))
      ]),
      transition(':leave', [
        animate('200ms ease-in', style({transform: 'translateX(200%)'}))
      ])
    ])
  ]
})
@UnRx()
export class PblExampleFormViewComponent extends ExampleViewComponent implements AfterViewInit {

  form: AbstractControl;
  nFormCmp: NFormComponent;

  formJson: string;
  modelJson: string;
  showSpinner: boolean;
  formStatus: string = 'UNKNOWN';

  @Input() noToolbar: boolean;
  @Input() rightDrawerOpened: boolean;
  @Input() jsonView: boolean;
  @Input() showSourceCode: boolean = false;

  ledBlinking: boolean;
  ledColor: 'red' | 'blue' | 'yellow' | 'green';

  constructor(private cdr: ChangeDetectorRef, 
              lazyModuleStore: LazyModuleStoreService,
              @Inject(MarkdownCodeExamplesService) protected exampleService: MarkdownCodeExamplesService,
              @Inject(EXAMPLE_COMPONENTS_TOKEN) protected exampleComponents: {[key: string]: any}) {
    super(lazyModuleStore, exampleService, exampleComponents);
  }

  ngAfterViewInit(): void {
    // Trigger change detection after view initialization
    this.cdr.detectChanges();
  }

  render(): void {
    super.render({ provide: PblExampleFormViewComponent, useValue: this });
  }

  toggleJsonView(): void {
    this.jsonView = !this.jsonView;
    if (this.jsonView) {
      this.refreshJsonView();
    }
  }

  onCommitToModel(): void {
    this.nFormCmp.nForm.commitToModel();
    this.refreshJsonView();
  }

  ngOnChanges(change: SimpleChanges): void {
    if ('rightDrawerOpened' in change) {
      this.rightDrawerOpened = coerceBooleanProperty(this.rightDrawerOpened);
    }
  }

  setNform(nform: NFormComponent): void {
    this.nFormCmp = nform;
    this.form = nform.form;
    this.formStatus = this.form.status;
    this.updateLedStatus(this.form.status);
    this.nFormCmp.valueChanges.pipe(debounceTime(150)).subscribe( v => this.refreshJsonView() );

    // Subscribe to form status changes and update asynchronously
    this.form.statusChanges.subscribe( status => {
      // Use Promise.resolve() to schedule the update in the next microtask
      // This ensures the change happens after the current change detection cycle
      Promise.resolve().then(() => {
        this.formStatus = status;
        this.updateLedStatus(status);
        this.cdr.markForCheck();
      });
    });
  }

  private updateLedStatus(status: string): void {
    switch (status) {
      case 'VALID':
        this.ledColor = 'green';
        this.ledBlinking = false;
        break;
      case 'INVALID':
        this.ledColor = 'red';
        this.ledBlinking = true;
        break;
      case 'PENDING':
        this.ledColor = 'blue';
        this.ledBlinking = true;
        break;
      case 'DISABLED':
        this.ledColor = 'yellow';
        this.ledBlinking = false;
        break;
      default:
        this.ledColor = <any> '';
    }
  }

  refreshJsonView(): void {
    if (this.jsonView) {
      this.formJson = hljs.highlightAuto(JSON.stringify(this.nFormCmp.form.getRawValue(), null, 2), ['json']).value;
      this.modelJson = hljs.highlightAuto(JSON.stringify(this.nFormCmp.nForm.model, null, 2), ['json']).value;
    }
  }
}
