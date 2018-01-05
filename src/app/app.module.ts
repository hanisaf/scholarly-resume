import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { HttpClientModule }    from '@angular/common/http';

import { AppComponent } from './app.component';
import {NoopAnimationsModule} from '@angular/platform-browser/animations';

import {KeysPipe} from './key.pipe';

import {
  MatTabsModule,
  MatCardModule,
  MatButtonModule
} from '@angular/material';


@NgModule({
  declarations: [
    AppComponent,
    KeysPipe
  ],
  imports: [
    BrowserModule,
    HttpClientModule,
    NoopAnimationsModule,
    MatTabsModule, 
    MatCardModule,
    MatButtonModule
  ],
  providers: [KeysPipe],
  bootstrap: [AppComponent]
})
export class AppModule { }
