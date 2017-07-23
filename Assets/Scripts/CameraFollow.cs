using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour {

    public float speed = 5.0f;
    public float speed2 = 1.0f;
    public Transform target;

    void LateUpdate () {

        transform.position = Vector3.Lerp(transform.position, target.position, speed * Time.deltaTime);
        transform.rotation = Quaternion.Lerp(transform.rotation, target.rotation, speed2 * Time.deltaTime);
       // transform.LookAt(target);
    }
}