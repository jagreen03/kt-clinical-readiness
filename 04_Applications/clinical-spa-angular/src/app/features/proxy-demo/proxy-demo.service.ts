import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../../environments/environment';

@Injectable({
  providedIn: 'root'
})
export class ProxyDemoService {
  private http = inject(HttpClient);

  fetchClinicalSample(): Observable<unknown> {
    return this.http.get<unknown>(`${environment.bffBaseUrl}/api/proxy/clinical/sample`);
  }
}